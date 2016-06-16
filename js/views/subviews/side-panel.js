import React from 'react';
import NowPlaying from './../../components/now-playing';
import Vote from './../../components/vote';

class SidePanel extends React.Component {
  nowPlayingHTML(track, time) {
    return <NowPlaying track={track} time={time} />
  }

  voteHTML(track, userId) {
    return <Vote track={track} userId={userId} />
  }

  render() {
    return (
      <div className='ui-side-panel'>
        { this.nowPlayingHTML(this.props.track, this.props.time) }
        { this.voteHTML(this.props.track, this.props.userId) }
      </div>
    );
  }
}

export default SidePanel;
