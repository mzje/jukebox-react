import React from 'react';

class NowPlaying extends React.Component {
  render() {
    if (this.props.track) {
      let trackTitle = this.props.track['title'];
      let artistName = this.props.track['artist'];
      return (
        <div>
          <p>{ artistName } '{ trackTitle }'</p>
        </div>
      );
    } else {
      return (
        <div>
          <p>Nothing is playing</p>
        </div>
      );
    }
  }
}

export default NowPlaying;
