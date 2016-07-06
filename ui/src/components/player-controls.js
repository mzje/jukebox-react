import React from 'react';

class PlayerControls extends React.Component {
  constructor(props) {
    super(props);
  }

  playOrPauseButton(playState) {
    console.log(playState)
    if (playState === 'play') {
      return(
        <button id="pause"><i className="fa fa-pause"></i> <span>Pause</span></button>
      )
    }
    else {
      return(
        <button id="play"><i className="fa fa-play"></i> <span>Play</span></button>
      )
    }
  }

  contentHTML(playState) {
    return(
      <div class="controls">
        <div class="player-controls">
          <button id="previous"><i class="fa fa-step-backward"></i> <span>Previous track</span></button>
          {this.playOrPauseButton(playState)}
          <button id="next"><i class="fa fa-step-forward"></i> <span>Next track</span></button>
        </div>
        <button id="clear_playlist">Clear playlist</button>
    </div>
    )
  }

  render() {
    return this.contentHTML(this.props.state)
  }
}

export default PlayerControls
