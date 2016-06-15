import React from 'react';

class TrackTime extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      time: this.props.time
    };
  }

  contentHTML(duration, time) {
    return(
      <div>
        <p>{this.seconds_to_time(time)} ({ duration })</p>
      </div>
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
      this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
    }
  }

  componentWillReceiveProps(nextProps) {
      // If a new track is about to start, the time is reset to 0
      if (nextProps.time < 2) {
        this.state.time = nextProps.time;
      }

      // Keep in sync when we get an UPDATE_TIME event
      if (this.props.time !== nextProps.time) {
        this.state.time = nextProps.time;
      }
  }

  render() {
    return this.contentHTML(this.props.duration, this.state.time)
  }
}

export default TrackTime;
