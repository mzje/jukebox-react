import React from 'react';

class Volume extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      volume: this.props.volume
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.volume !== null) {
      this.state.volume = nextProps.volume;
    }
  }

  contentHTML(volume) {
    return (
      <div className="ui-volume-container">
        <label htmlFor="volume">Volume</label>
        <i className="fa fa-volume-down"></i>
        <input
          className="ui-volume-slider"
          type="range"
          min="0"
          max="100"
          value={volume || 0}
          onChange={this.updateVolume}
        />
        <i className="fa fa-volume-up"></i>
      </div>
    );
  }

  updateVolume = (event) => {

  }


  render() {
    return this.contentHTML(this.state.volume);
  }
}

export default Volume;
