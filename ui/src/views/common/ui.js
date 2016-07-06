import React from 'react';
import Store from './../../stores/store';
import Jukebox from './../../utils/jukebox';
import SidePanel from './side-panel';
import Header from './header';

class UI extends React.Component {
  static propTypes = {
    children: React.PropTypes.element.isRequired
  }

  static childContextTypes = {
    jukebox: React.PropTypes.object
  }

  constructor(props) {
    super(props);
    const store = Store;
    this.state = {
      jukebox: new Jukebox(),
      store: store,
      storeData: store.currentState()
    };
  }

  getChildContext = () => ({
    jukebox: this.state.jukebox
  });

  componentDidMount() {
    this.state.store.addChangeListener(this._onChange);
    this.state.jukebox.openConnection();
  }

  componentWillUnmount() {
    this.state.store.removeChangeListener(this._onChange);
  }

  sidePanelHTML(track, userId, time, volume, playState) {
    return(
      <SidePanel track={track} userId={userId} time={time} volume={volume} playState={playState} />
    )
  }

  headerHTML(connection) {
    return <Header connection={connection} />;
  }

  /**
   * Event handler for 'change' events coming from the Store
   */
  _onChange = () => {
    this.setState({
      storeData: this.state.store.currentState()
    });
  }

  render() {
    const track = this.state.storeData.get('track');
    const userId = this.state.storeData.get('user_id');
    const time = this.state.storeData.get('time');
    const connection = this.state.storeData.get('connection');
    const volume = this.state.storeData.get('volume');
    const playState = this.state.storeData.get('playState');
    return (
      <div className="ui-container">
        {this.sidePanelHTML(track, userId, time, volume, playState)}
        <main className="ui-content">
          {this.headerHTML(connection)}
          {this.props.children}
        </main>
      </div>
    );
  }
}

export default UI;
