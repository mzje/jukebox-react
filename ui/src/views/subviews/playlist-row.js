import React from 'react';
import Store from './../../stores/store';

class PlaylistRow extends React.Component {

  rowHTML(track) {
    return <td>{ track.get('artist') } { track.get('title') }</td>
  }

  render() {
    return (
      <div className='ui-playlist'>
        { this.rowHTML(this.props.track) }
      </div>
    );
  }
}

export default PlaylistRow;
