import React from 'react';
import TrackTime from './track-time';

class NowPlaying extends React.Component {
  contentHTML(track, time) {
    if (track) {
      return this.trackInfoHTML(
        track['filename'],
        track['title'],
        track['artist'],
        track['artwork_url'],
        track['added_by'],
        track['duration'],
        time
      )
    } else {
      return this.loadingHTML()
    }
  }

  trackInfoHTML(filename, artistName, trackTitle, artworkUrl, addedBy, duration, time) {
    return (
      <div>
        <h1>{ artistName }</h1>
        <p>'{ trackTitle }'</p>
        <img src={ artworkUrl } width='100px' height='100px' />
        <p>Chosen by { addedBy }</p>
        <TrackTime duration={duration} time={time} />
      </div>
    );
  }

  loadingHTML() {
    return (
      <div>
        <p>Loading...</p>
      </div>
    );
  }

  render() {
    return this.contentHTML(this.props.track, this.props.time)
  }
}

export default NowPlaying;
