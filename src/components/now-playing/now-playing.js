import React from 'react';

class NowPlaying extends React.Component {
  render() {
    let trackTitle;
    if (this.props.track) {
      trackTitle = this.props.track['title'];
    } else {
      trackTitle = 'Nothing is playing'
    }
    return (
      <div>
        <p>'{ trackTitle }'</p>
      </div>
    );
  }
}

export default NowPlaying;
