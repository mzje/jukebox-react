var AppDispatcher = require('../dispatcher/AppDispatcher');
var EventEmitter = require('events').EventEmitter;
var Constants = require('../constants/constants');
var assign = require('object-assign');
import Jukebox from '../utils/jukebox';

var CHANGE_EVENT = 'change';

var _data = {};

function updateTrack(track) {
  _data['track'] = track;
}

var Store = assign({}, EventEmitter.prototype, {

  currentState: () => {
    _data;
  },

  track: () => {
    return _data['track'];
  },

  emitChange: function() {
    this.emit(CHANGE_EVENT);
  },

  /**
   * @param {function} callback
   */
  addChangeListener: function(callback) {
    this.on(CHANGE_EVENT, callback);
  },

  /**
   * @param {function} callback
   */
  removeChangeListener: function(callback) {
    this.removeListener(CHANGE_EVENT, callback);
  }
});

// Register callback to handle all updates
AppDispatcher.register(function(action) {
  var text;

  switch(action.actionType) {
    case Constants.UPDATE_TRACK:
      updateTrack(action.track);
      Store.emitChange();
      break;

    case Constants.TODO_CREATE:
      text = action.text.trim();
      if (text !== '') {
        create(text);
        Store.emitChange();
      }
      break;

    default:
      // no op
  }
});

module.exports = Store;
