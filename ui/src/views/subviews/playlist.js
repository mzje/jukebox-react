import React from 'react';
import Store from './../../stores/store';
import PlaylistRow from './playlist-row';

class Playlist extends React.Component {
  constructor(props) {
    super(props);
    const store = Store;
    this.state = {
      store: store,
      storeData: store.currentState()
    };
  }

  componentDidMount() {
    this.state.store.addChangeListener(this._onChange.bind(this));
  }

  componentWillUnmount() {
    this.state.store.removeChangeListener(this._onChange.bind(this));
  }

  /**
   * Event handler for 'change' events coming from the Store
   */
  _onChange() {
    this.setState({
      storeData: this.state.store.currentState()
    });
  }

  rowsHTML(playlist, currentTrack) {
    return playlist.get('tracks').map(this.rowHTML(currentTrack));
  }

  rowHTML = (currentTrack) => (track) => {
    let current = currentTrack.get('filename') === track.get('filename');
    return <PlaylistRow track={track} current={current} />;
  };

  playlistHTML(playlist, currentTrack) {
    let html;
    if (playlist) {
      html = (
        <table className='ui-playlist-table'>
          <tbody>
            {this.rowsHTML(playlist, currentTrack)}
          </tbody>
        </table>
      );
    }
    return html;
  }

  render() {
    const playlist = this.state.storeData.get('playlist');
    const currentTrack = this.state.storeData.get('track');
    return (
      <div className="ui-playlist">
        {this.playlistHTML(playlist, currentTrack)}
      </div>
    );
  }
}

export default Playlist;
