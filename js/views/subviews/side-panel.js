import React from 'react';
import NowPlaying from './../../components/now-playing';
import Volume from './../../components/volume';
import PlayerControls from './../../components/player-controls';
import Vote from './../../components/vote';

class SidePanel extends React.Component {

  volumeHTML(volume) {
    return <Volume volume={volume} />
  }

  nowPlayingHTML(track) {
    return <NowPlaying track={track} />
  }

  voteHTML(track, userId) {
    return <Vote track={track} userId={userId} />
  }

  playerControlsHTML(state) {
    return <PlayerControls state={state} />
  }

  render() {
    return (
      <div className='ui-side-panel'>
        { this.volumeHTML(this.props.volume) }
        { this.nowPlayingHTML(this.props.track) }
        { this.playerControlsHTML(this.props.play_state) }
        { this.voteHTML(this.props.track, this.props.userId) }
      </div>
    );
  }
}

export default SidePanel;
