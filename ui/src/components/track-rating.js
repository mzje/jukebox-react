import React from 'react';

class TrackRating extends React.Component {
  static propTypes = {
    rating: React.PropTypes.oneOfType([
      React.PropTypes.string,
      React.PropTypes.number
    ]),
    ratingClass: React.PropTypes.string
  }

  render() {
    if (this.props.rating) {
      return (
        <p className={this.props.ratingClass}>{this.props.rating}</p>
        );
    }
    return false;
  }
}

export default TrackRating;
