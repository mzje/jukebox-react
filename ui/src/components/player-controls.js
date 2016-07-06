import React from 'react';

class PlayerControls extends React.Component {

  static propTypes = {
    playState: React.PropTypes.string
  }

  previousButton() {
    return (
      <button className="ui-player-controls__previous">
        <i className="fa fa-step-backward"></i>
        <span>Previous track</span>
      </button>
    );
  }

  nextButton() {
    return (
      <button className="ui-player-controls__next">
        <i className="fa fa-step-forward"></i>
        <span>Next track</span>
      </button>
    );
  }

  pauseButton() {
    return (
      <button id="pause">
        <i className="fa fa-pause"></i>
        <span>Pause</span>
      </button>
    );
  }

  playButton() {
    return (
      <button id="play">
        <i className="fa fa-play"></i>
        <span>Play</span>
      </button>
    );
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
