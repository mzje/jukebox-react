var AppDispatcher = require('../dispatcher/AppDispatcher');
var Constants = require('../constants/constants');

var Actions = {
  updateTrack: (track) => {
    AppDispatcher.dispatch({
      actionType: Constants.UPDATE_TRACK,
      track: track
    });
  }
};

module.exports = Actions;
