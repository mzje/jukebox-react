import React from 'react';

class PlaylistRow extends React.Component {
  static propTypes = {
    track: React.PropTypes.object
  }

  rowHTML(track) {
    return <td>{track.get('artist')} {track.get('title')}</td>;
  }

  render() {
    return (
      <div className="ui-playlist">
        {this.rowHTML(this.props.track)}
      </div>
    );
  }
}

export default PlaylistRow;
