import React from 'react';
import NowPlaying from './../now-playing';
import Jukebox from './../jukebox';

class UI extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      track: {},
      rating: {},
      playlist: {},
      volume: 0,
      playing: false,
      time: 0,
      timer: null,
      current_user_id: '',
      current_user_initials: ''
    };
  }

  componentDidMount() {
    console.log('UI Mounted!')
    new Jukebox().openConnection(this);
  }

  render() {
    return (
      <div>
        <NowPlaying track={this.state.track} />
      </div>
    );
  }
}

export default UI;
