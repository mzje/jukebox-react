import React from 'react';

class ProgressBar extends React.Component {
  static propTypes = {
    time: React.PropTypes.number.isRequired,
    duration: React.PropTypes.string.isRequired
  }

  percentagePlayed() {
    return Math.floor(this.props.time / this.durationToSeconds() * 100);
  }

  durationToSeconds() {
    const parts = this.props.duration.split(':');
    const mins = parseInt(parts[0], 10);
    const seconds = parseInt(parts[1], 10);
    return (mins * 60) + seconds;
  }

  render() {
    return (
      <div className="progressBarContainer">
        <div className="progressBarContent" style={{ width: `${this.percentagePlayed()}%` }} />
      </div>
    );
  }
}

export default ProgressBar;
