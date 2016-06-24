import React from 'react';
import TrackTime from './track-time';

class NowPlaying extends React.Component {
  static propTypes = {
    track: React.PropTypes.object,
    time: React.PropTypes.string
  }

  contentHTML(track, time) {
    if (track) {
      return this.trackInfoHTML(
        track.filename,
        track.title,
        track.artist,
        track.artwork_url,
        track.added_by,
        track.duration,
        track.rating,
        track.rating_class,
        time
      );
    }

    return this.loadingHTML();
  }

  trackInfoHTML(filename, artistName, trackTitle, artworkUrl, addedBy, duration, rating, rating_class, time) {
    return (
      <div>
        <h1>{artistName}</h1>
        <p>'{trackTitle}'</p>
        <img src={artworkUrl} width="100px" height="100px" alt={artistName} />
        <p>Chosen by {addedBy}</p>
        <p className={rating_class}>{rating}</p>
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
    return this.contentHTML(this.props.track, this.props.time);
  }
}

export default NowPlaying;
