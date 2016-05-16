var Dispatcher = require('../dispatcher/dispatcher');
var Constants = require('../constants/constants');

var Actions = {
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
  }
};

module.exports = Actions;
