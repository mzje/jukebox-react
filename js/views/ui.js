import React from 'react';
import Store from '../stores/store';
import Actions from '../actions/actions';
import Jukebox from './../utils/jukebox';
import SidePanel from './subviews/side-panel';

class UI extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      jukebox: new Jukebox(),
      store: {}
    };
  }

  static childContextTypes = {
    jukebox: React.PropTypes.object
  }

  getChildContext = () => {
    return {
      jukebox: this.state.jukebox
    }
  }

  updateUserID = (onChangeEvent) => {
    console.log(onChangeEvent.target.value);
    Actions.updateUserID(onChangeEvent.target.value);
  }

  componentDidMount() {
    Store.addChangeListener(this._onChange.bind(this));
    this.state.jukebox.openConnection();
  }

  componentWillUnmount() {
    Store.removeChangeListener(this._onChange.bind(this));
  }

  sidePanelHTML(track, userId) {
    return(
      <SidePanel track={track} userId={userId} />
    )
  }

  /**
   * Event handler for 'change' events coming from the Store
   */
  _onChange() {
    this.setState({
      store: Store.currentState()
    });
  }

  render() {
    let track = this.state.store.track;
    let userId = this.state.store.user_id;
    return (
      <div>
        <label>
          User ID: <input type='text' onChange={this.updateUserID.bind(this)} />
        </label>
        { this.sidePanelHTML(track, userId) }
      </div>
    );
  }
}

export default UI;
