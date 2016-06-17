import React from 'react';
import Store from './../../stores/store';
import PlaylistRow from './playlist-row';

class Playlist extends React.Component {
  constructor(props) {
    super(props);
    let store = Store
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

  rowHTML = (track) => {
    return <PlaylistRow track={track} />
  }

  playlistHTML(playlist) {
    console.log('playlistHTML');
    console.log(playlist);
    let yes
    if(playlist) {
      yes = 'true'

    } else {
      yes = 'false'
    }
    console.log(
      yes
    );
    if(playlist) {
      console.log('show playlist')
      return(
        <table>
          <tbody>
            { this.rowsHTML(playlist) }
          </tbody>
        </table>
      );
    } else {
      return null
    }
  }

  render() {
    let playlist = this.state.storeData.get('playlist');
    return (
      <div className="ui-playlist">
        {this.playlistHTML(playlist)}
      </div>
    );
  }
}

export default Playlist;
