import React from 'react';

class Playlist extends React.Component {
  playlistHTML() {
    return(
      <p>Playlist goes here...</p>
    );
  }

  render() {
    return (
      <div className='ui-playlist'>
        { this.playlistHTML() }
      </div>
    );
  }
}

export default Playlist;
