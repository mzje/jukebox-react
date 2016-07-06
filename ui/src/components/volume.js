import React from 'react';

class Volume extends React.Component {
  static contextTypes = {
    jukebox: React.PropTypes.object
  }

  static propTypes = {
    volume: React.PropTypes.string,
    userId: React.PropTypes.string
  }

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
          onChange={this.updateSlider}
          onMouseUp={this.updateVolume}
        />
        <i className="fa fa-volume-up"></i>
      </div>
    );
  }

  // Send the final volume value to the jukebox
  updateVolume = (event) => {
    this.context.jukebox.setVolume(this.props.userId, event.target.value);
  }

  // Update the slider value so that the slider moves as you slide
  updateSlider = (event) => {
    this.setState({ volume: event.target.value });
  }

  render() {
    return this.contentHTML(this.state.volume);
  }
}

export default Volume;
