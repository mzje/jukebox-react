import React from 'react';

class NowPlaying extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      time: this.props.time
    };
  }

  contentHTML(track, time) {
    if (track) {
      return this.trackInfoHTML(
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

  componentDidMount() {
    let timeUpdater = setInterval(() => {
      if(this.props.time) {
        this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
      }
    }, 1000);
  }

  trackInfoHTML(artistName, trackTitle, artworkUrl, addedBy, duration, time) {
    return (
      <div>
        <h1>{ artistName }</h1>
        <p>'{ trackTitle }'</p>
        <img src={ artworkUrl } width='100px' height='100px' />
        <p>Chosen by { addedBy }</p>
        <p>Duration { duration }</p>
        <p>Time: {time}</p>
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
    return this.contentHTML(this.props.track, this.state.time)
  }
}

export default NowPlaying;
