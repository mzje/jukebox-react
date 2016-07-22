import React from 'react';

class PlaylistRow extends React.Component {
  static propTypes = {
    track: React.PropTypes.object.isRequired,
    current: React.PropTypes.bool.isRequired
  }

  rowHTML(track) {
    return (
      [
        <td className="ui-playlist-cell ui-playlist-cell__title" key="title">
          {track.get('title')}
        </td>,
        <td className="ui-playlist-cell ui-playlist-cell__artist" key="artist">
          {track.get('artist')}
        </td>,
        <td className="ui-playlist-cell ui-playlist-cell__album" key="album">
          {track.get('album')}
        </td>,
        <td className="ui-playlist-cell ui-playlist-cell__rating" key="rating">
          <span className={track.get('rating_class')}>
            {track.get('rating')}
          </span>
        </td>,
        <td className="ui-playlist-cell ui-playlist-cell__added-by" key="added_by">
          {track.get('added_by')}
        </td>
      ]
    );
  }

  get classNames() {
    const classes = ['ui-playlist-row'];
    if (this.props.current) {
      classes.push('ui-playlist-row--current');
    }
    return classes.join(' ');
  }

  render() {
    return (
      <tr className={this.classNames} key={`track-${this.props.track.get('dbid')}`}>
        {this.rowHTML(this.props.track)}
      </tr>
    );
  }
}

export default PlaylistRow;
