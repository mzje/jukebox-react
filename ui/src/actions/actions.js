import Dispatcher from '../dispatcher/dispatcher';
import Constants from '../constants/constants';

const Actions = {
  connectionOpen: () => {
    Dispatcher.dispatch({
      actionType: Constants.CONNECTION_OPEN
    });
  },

  connectionError: (message) => {
    Dispatcher.dispatch({
      actionType: Constants.CONNECTION_ERROR,
      message: message
    });
  },

  connectionClosed: (message) => {
    Dispatcher.dispatch({
      actionType: Constants.CONNECTION_CLOSED,
      message: message
    });
  },

  updateTrack: (track) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_TRACK,
      track: track
    });
  },

  updateUserID: (userID) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_USER_ID,
      userID: userID
    });
  },

  updateVolume: (volume) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_VOLUME,
      volume: volume
    });
  },

  updatePlayState: (playState) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_PLAYSTATE,
      playState: playState
    });
  },

  updateTime: (time) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_TIME,
      time: time
    });
  },

  updateRating: (rating) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_RATING,
      rating: rating
    });
  },

  updatePlaylist: (playlist) => {
    Dispatcher.dispatch({
      actionType: Constants.UPDATE_PLAYLIST,
      playlist: playlist
    });
  },

  removePlaylistTrack: (track) => {
    Dispatcher.dispatch({
      actionType: Constants.REMOVE_PLAYLIST_TRACK,
      track: track
    });
  }
};

module.exports = Actions;
