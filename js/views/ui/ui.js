import React from 'react';
import Dispatcher from './../../dispatcher/dispatcher';
import Immutable from 'immutable'
import Store from './../../stores/store';
import Jukebox from './../../utils/jukebox';
import SidePanel from './side-panel';
import Header from './header';

class UI extends React.Component {
  constructor(props) {
    super(props);
    let store = Store
    this.state = {
      jukebox: new Jukebox(),
      store: store,
      storeData: store.currentState()
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

  componentDidMount() {
    this.state.store.addChangeListener(this._onChange.bind(this));
    this.state.jukebox.openConnection();
  }

  componentWillUnmount() {
    this.state.store.removeChangeListener(this._onChange.bind(this));
  }

  sidePanelHTML(track, userId, time) {
    return(
      <SidePanel track={track} userId={userId} time={time} />
    )
  }

  headerHTML(connection) {
    return <Header connection={connection} />
  }

  /**
   * Event handler for 'change' events coming from the Store
   */
  _onChange() {
    this.setState({
      storeData: this.state.store.currentState()
    });
  }

  render() {
    let track = this.state.storeData.get('track');
    let userId = this.state.storeData.get('user_id');
    let time = this.state.storeData.get('time');
    let connection = this.state.storeData.get('connection');
    return (
      <div>
        { this.headerHTML(connection) }
        { this.sidePanelHTML(track, userId, time) }
        { this.props.children }
      </div>
    );
  }
}

export default UI;
