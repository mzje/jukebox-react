import React from 'react';

class PlayerControls extends React.Component {
  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  static propTypes = {
    playState: React.PropTypes.string,
    userId: React.PropTypes.string
  }

  previousButton() {
    return (
      <button className="ui-player-controls__previous" onClick={this.previous}>
        <i className="fa fa-step-backward"></i>
        <span>Previous track</span>
      </button>
    );
  }

  nextButton() {
    return (
      <button className="ui-player-controls__next" onClick={this.next}>
        <i className="fa fa-step-forward"></i>
        <span>Next track</span>
      </button>
    );
  }

  pauseButton() {
    return (
      <button className="ui-player-controls__pause" onClick={this.pause}>
        <i className="fa fa-pause"></i>
        <span>Pause</span>
      </button>
    );
  }

  playButton() {
    return (
      <button className="ui-player-controls__play" onClick={this.play}>
        <i className="fa fa-play"></i>
        <span>Play</span>
      </button>
    );
  }

  play = () => {
    this.context.jukebox.play();
  }

  pause = () => {
    this.context.jukebox.pause();
  }

  next = () => {
    this.context.jukebox.next();
  }

  previous = () => {
    this.context.jukebox.previous();
  }

  playOrPauseButton(playState) {
    let button;
    if (playState === 'play') {
      button = this.pauseButton();
    } else {
      button = this.playButton();
    }
    return button;
  }

  clearPlaylistButton() {
    return (
      <button className="ui-player-controller__clear-playlist">
        Clear playlist
      </button>
    );
  }

  contentHTML(playState) {
    return (
      <div className="ui-player-controls__container">
        <div className="ui-player-controls">
          {this.previousButton()}
          {this.playOrPauseButton(playState)}
          {this.nextButton()}
        </div>
        {this.clearPlaylistButton()}
      </div>
    );
  }

  render() {
    return this.contentHTML(this.props.playState);
  }
}

export default PlayerControls;
