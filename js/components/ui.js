import React from 'react';
import NowPlaying from './now-playing';
import Jukebox from './../utils/jukebox';
import Store from '../stores/store';

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
        <NowPlaying track={Store.track()} />
      </div>
    );
  }
}

export default UI;
