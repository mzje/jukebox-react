import React from 'react';
import Actions from '../actions/actions';

class Vote extends React.Component {
  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  voteUp(event) {
    event.preventDefault();
    this.context.jukebox.vote(this.props.userId, this.props.track, 1);
  }

  render() {
    if (this.props.track && this.props.userId) {
      return (
        <a href='#' onClick={this.voteUp.bind(this)}>Upvote</a>
      );
    } else {
      return null;
    };
  }
}

export default Vote;
