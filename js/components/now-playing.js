import React from 'react';

class NowPlaying extends React.Component {
  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  voteUp(event) {
    event.preventDefault();
    console.log('voteUp');
    this.context.jukebox.vote(this.props.track, 1);
  }

  render() {
    if (this.props.track) {
      let trackTitle = this.props.track['title'];
      let artistName = this.props.track['artist'];
      return (
        <div>
          <h1>Foo { artistName }</h1>
          <p>'{ trackTitle }'</p>
          <a href='' onClick={this.voteUp.bind(this)}>Upvote</a>
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
