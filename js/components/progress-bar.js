import React from 'react';

class ProgressBar extends React.Component {
  static propTypes = {
    time: React.PropTypes.number.isRequired,
    duration: React.PropTypes.string.isRequired
  }

  percentage_played() {
    return Math.floor(this.props.time / this.duration_to_seconds() * 100)
  }

  duration_to_seconds() {
    let parts = this.props.duration.split(':')
    let mins = parseInt(parts[0])
    let seconds = parseInt(parts[1])
    return (mins * 60) + seconds
  }

  render() {
    return(
      <div className='progressBarContainer'>
        <div className='progressBarContent' style={{ 'width': this.percentage_played() + '%' }}></div>
      </div>
    );
  }
}

export default ProgressBar;
