import React from 'react';
import NowPlaying from './../../components/now-playing';
import Vote from './../../components/vote';
import Volume from './../../components/volume';
import PlayerControls from './../../components/player-controls';

class SidePanel extends React.Component {
  static propTypes = {
    track: React.PropTypes.object,
    time: React.PropTypes.string
  };

  volumeHTML(volume) {
    return <Volume volume={volume} />
  }

  playerControlsHTML(playState) {
    return <PlayerControls playState={playState} />
  }

  nowPlayingHTML(track, time) {
    return <NowPlaying track={track} time={time} />;
  }

  voteHTML(track) {
    return <Vote track={track} />;
  }

  render() {
    return (
      <div className="ui-side-panel">
        {this.volumeHTML(this.props.volume)}
        {this.nowPlayingHTML(this.props.track, this.props.time)}
        {this.voteHTML(this.props.track)}
        {this.playerControlsHTML(this.props.playState)}
      </div>
    );
  }
}

export default SidePanel;
