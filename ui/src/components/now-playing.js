import React from 'react';
import TrackTime from './track-time';
import TrackRating from './track-rating';

class NowPlaying extends React.Component {
  static propTypes = {
    track: React.PropTypes.object,
    time: React.PropTypes.string
  }

  contentHTML(track, time) {
    if (track) {
      return this.trackInfoHTML(
        track.get('filename'),
        track.get('title'),
        track.get('artist'),
        track.get('artwork_url'),
        track.get('added_by'),
        track.get('duration'),
        track.get('rating'),
        track.get('rating_class'),
        time
      );
    }

    return this.loadingHTML();
  }

  trackInfoHTML(filename,
                artistName,
                trackTitle,
                artworkUrl,
                addedBy,
                duration,
                rating,
                ratingClass,
                time) {
    return (
      <div>
        <h1>{artistName}</h1>
        <p>'{trackTitle}'</p>
        <TrackRating rating={rating} ratingClass={ratingClass} />
        <img src={artworkUrl} width="100px" height="100px" alt={artistName} />
        <p>Chosen by {addedBy}</p>
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
