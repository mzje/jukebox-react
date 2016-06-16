import React from 'react';

class Volume extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      volume: this.props.volume
    }
    this.updateVolume = this.updateVolume.bind(this)
  }

  updateVolume(event) {
    // TODO
    console.log('Trying to set volume to. Not currently implemented.')
    this.setState({'volume':  event.target.value})
  }

  contentHTML(volume) {
    return(
      <div id="volume_control">
          <label for="volume">Volume</label>
          <i class="fa fa-volume-down"></i>
          <input id="volume" type="range" min="0" max="100" value={volume || 0} onChange={this.updateVolume} />
          <i class="fa fa-volume-up"></i>
      </div>
    );
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.volume !== null) {
      this.state.volume = nextProps.volume
    }
  }


  render() {
    return this.contentHTML(this.state.volume)
  }
}

export default Volume;