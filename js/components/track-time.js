import React from 'react';
import ProgressBar from './progress-bar'

class TrackTime extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      time: this.props.time
    };
  }

  contentHTML(duration, time) {
    if(typeof(duration) === 'string' && typeof(time) === 'number') {
      return(
        <div>
          <ProgressBar duration={duration} time={time} />
          { this.currentTimeHTML(duration, time) }
        </div>
      );
    } else {
      return null
    }
  }

  currentTimeHTML(duration, time) {
    return(
      <p>{this.seconds_to_time(time)} ({ duration })</p>
    );
  }

  seconds_to_time(seconds) {
    let minutes = seconds/60;
    let padded = function(number){
      number = number+'';
      return number.length<2 ? '0'+number : number;
    }
    return padded(Math.floor(minutes)) + ':' + padded(seconds%60);
  }

  componentDidMount() {
    this.interval = setInterval(this.tick.bind(this), 1000)
  }

  tick() {
    if(this.props.time) {
      this.setState({time: parseInt(this.state.time, 10) + 1})
    }
  }

  componentWillReceiveProps(nextProps) {
    this.syncTime(nextProps.time)
  }

  syncTime(newTime) {
    if (this.props.time !== newTime) {
      this.setState({time: newTime});
    }
  }

  render() {
    return this.contentHTML(this.props.duration, this.state.time)
  }
}

export default TrackTime;
