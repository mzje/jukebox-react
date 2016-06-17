import React from 'react';

class Vote extends React.Component {
  static propTypes = {
    userId: React.PropTypes.number,
    track: React.PropTypes.object
  }

  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  voteUp = (event) => {
    event.preventDefault();
    this.context.jukebox.vote(this.props.userId, this.props.track, 1);
  }

  voteHTML() {
    return (
      <a href="#" onClick={this.voteUp}>Upvote</a>
    );
  }

  render() {
    let html = null;
    if (this.props.track && this.props.userId) {
      html = this.voteHTML();
    }
    return html;
  }
}

export default Vote;
