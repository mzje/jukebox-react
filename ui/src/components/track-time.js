import React from 'react';
import ProgressBar from './progress-bar';

class TrackTime extends React.Component {
  static propTypes = {
    time: React.PropTypes.oneOfType([
      React.PropTypes.string,
      React.PropTypes.number
    ]),
    duration: React.PropTypes.string
  }

  constructor(props) {
    super(props);
    this.state = {
      time: this.props.time
    };
  }

  componentDidMount() {
    this.interval = setInterval(this.tick.bind(this), 1000);
  }

  componentWillReceiveProps(nextProps) {
    this.syncTime(nextProps.time);
  }

  contentHTML(duration, time) {
    if (typeof(duration) !== 'undefined' && typeof(time) !== 'undefined') {
      return (
        <div>
          <ProgressBar duration={duration} time={time} />
          {this.currentTimeHTML(duration, time)}
        </div>
      );
    }

    return null;
  }

  currentTimeHTML(duration, time) {
    return (
      <p>{this.secondsToTime(time)} ({duration})</p>
    );
  }

  secondsToTime(seconds) {
    const minutes = seconds / 60;
    const padded = function padded(number) {
      return (String(number).length < 2) ? `0${number}` : number;
    };
    return `${padded(Math.floor(minutes))}:${padded(seconds % 60)}`;
  }

  tick() {
    if (this.props.time) {
      this.setState({ time: parseInt(this.state.time, 10) + 1 });
    }
  }

  syncTime(newTime) {
    if (this.props.time !== newTime) {
      this.setState({ time: newTime });
    }
  }

  render() {
    return this.contentHTML(this.props.duration, this.state.time);
  }
}

export default TrackTime;
