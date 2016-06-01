import React from 'react';
import NowPlaying from './../../components/now-playing';
import Vote from './../../components/vote';

class SidePanel extends React.Component {
  nowPlayingHTML(track) {
    return <NowPlaying track={track} />
  }

  voteHTML(track, userId) {
    return <Vote track={track} userId={userId} />
  }

  render() {
    return (
      <div className='ui-side-panel'>
        { this.nowPlayingHTML(this.props.track) }
        { this.voteHTML(this.props.track, this.props.userId) }
      </div>
    );
  }
}

export default SidePanel;
