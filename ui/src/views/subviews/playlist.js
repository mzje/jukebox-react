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

  rowsHTML(playlist) {
    return playlist.get('tracks').map(this.rowHTML);
  }

  rowHTML = (track) => <PlaylistRow track={track} />

  playlistHTML(playlist) {
    let html;
    if (playlist) {
      html = (
        <table>
          <tbody>
            {this.rowsHTML(playlist)}
          </tbody>
        </table>
      );
    }
    return html;
  }

  render() {
    const playlist = this.state.storeData.get('playlist');
    return (
      <div className="ui-playlist">
        {this.playlistHTML(playlist)}
      </div>
    );
  }
}

export default Playlist;
