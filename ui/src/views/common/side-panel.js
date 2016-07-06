import React from 'react';
import NowPlaying from './../../components/now-playing';
import Vote from './../../components/vote';
import Volume from './../../components/volume';
import PlayerControls from './../../components/player-controls';

class SidePanel extends React.Component {
  static propTypes = {
    track: React.PropTypes.object,
    time: React.PropTypes.string,
    userId: React.PropTypes.string
  };

  volumeHTML(volume, userId) {
    return <Volume volume={volume} userId={userId} />
  }

  playerControlsHTML(playState, userId) {
    return <PlayerControls playState={playState} userId={userId} />
  }

  nowPlayingHTML(track, time) {
    return <NowPlaying track={track} time={time} />;
  }

  voteHTML(track, userId) {
    return <Vote track={track} userId={userId} />;
  }

  render() {
    return (
      <div className="ui-side-panel">
        {this.volumeHTML(this.props.volume, this.props.userId)}
        {this.nowPlayingHTML(this.props.track, this.props.time)}
        {this.voteHTML(this.props.track, this.props.userId)}
        {this.playerControlsHTML(this.props.playState)}
      </div>
    );
  }
}

export default SidePanel;
