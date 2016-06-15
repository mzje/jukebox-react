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
    //this.timeUpdater();
    this.interval = setInterval(this.tick.bind(this), 1000)
    // this.interval = setInterval(() => {
    //   if(this.props.time) {
    //     this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
    //   }
    // }, 1000);
    // var timeUpdater = setInterval(() => {
    //   if(this.props.time) {
    //     this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
    //   }
    // }, 1000);
  }

  tick() {
    if(this.props.time) {
      this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
    }
  }

  // timeUpdater = setInterval(() => {
  //   if(this.props.time) {
  //     this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
  //   }
  // }, 1000);

  componentWillUpdate(nextProps) {
    if (nextProps.filename !== this.props.filename) {
      console.log('componentWillUpdate')
      console.log(this.props.filename);
      console.log(nextProps.filename);
      clearInterval(this.interval);
      this.interval = setInterval(this.tick.bind(this), 1000)
      // var timeUpdater = setInterval(() => {
      //   if(this.props.time) {
      //     this.setState({time: parseInt(this.state.time || this.props.time, 10) + 1})
      //   }
      // }, 1000);
    }
  }

  render() {
    return this.contentHTML(this.props.duration, this.state.time)
  }
}

export default TrackTime;
