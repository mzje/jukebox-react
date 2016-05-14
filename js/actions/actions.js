var AppDispatcher = require('../dispatcher/AppDispatcher');
var Constants = require('../constants/constants');

var Actions = {
  updateTrack: (track) => {
    AppDispatcher.dispatch({
      actionType: Constants.UPDATE_TRACK,
      track: track
    });
  },

  updateUserID: (userID) => {
    AppDispatcher.dispatch({
      actionType: Constants.UPDATE_USER_ID,
      userID: userID
    });
  }
};

module.exports = Actions;
