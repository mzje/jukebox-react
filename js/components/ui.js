import React from 'react';
import Store from '../stores/store';
import Actions from '../actions/actions';
import Jukebox from './../utils/jukebox';
import NowPlaying from './now-playing';
import Vote from './vote';

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

  /**
   * Event handler for 'change' events coming from the Store
   */
  _onChange() {
    this.setState({
      store: Store.currentState()
    });
  }

  render() {
    return (
      <div>
        <label>
          User ID: <input type='text' onChange={this.updateUserID.bind(this)} />
        </label>
        <NowPlaying track={Store.track()} />
        <Vote track={Store.track()} userID={Store.userID()} />
      </div>
    );
  }
}

export default UI;
