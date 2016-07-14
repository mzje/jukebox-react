import React from 'react';

class Vote extends React.Component {
  static propTypes = {
    track: React.PropTypes.object
  }

  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  voteUp = (event) => {
    event.preventDefault();
    this.context.jukebox.vote(this.props.track, 1);
  }

  voteHTML() {
    return (
      <a href="#" onClick={this.voteUp}>Upvote</a>
    );
  }

  userID() {
    let userID = null;
    if (this.context.jukebox) {
      userID = this.context.jukebox.userID;
    }
    return userID;
  }

  render() {
    let html = null;
    if (this.props.track && this.userID()) {
      html = this.voteHTML();
    }
    return html;
  }
}

export default Vote;
