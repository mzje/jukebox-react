import Dispatcher from '../dispatcher/dispatcher';
import { EventEmitter } from 'events';
import Constants from '../constants/constants';
import Immutable from 'immutable';

const CHANGE_EVENT = 'change';

const defaultData = Immutable.fromJS({
  track: null,
  user_id: null,
  volume: null,
  playState: null,
  time: null,
  playlist: null,
  connection: {
    open: false,
    error_message: null,
    closed_message: null
  }
});

class Store extends EventEmitter {

  constructor(dispatcher, data) {
    super(dispatcher, data);
    this.dispatchToken = dispatcher.register(this.dispatcherCallback.bind(this));
    this.data = data;
  }

  [Constants.CONNECTION_OPEN]() {
    this.data = this.data.setIn(['connection', 'open'], true);
  }

  [Constants.CONNECTION_ERROR](action) {
    this.data = this.data.setIn(['connection', 'error_message'], action.message);
  }

  [Constants.CONNECTION_CLOSED](action) {
    this.data = this.data.setIn(['connection', 'open'], false);
    this.data = this.data.setIn(['connection', 'closed_message'], action.message);
  }

  [Constants.UPDATE_VOLUME](action) {
    this.data = this.data.set('volume', action.volume);
  }

  [Constants.UPDATE_PLAYSTATE](action) {
    this.data = this.data.set('playState', action.playState);
  }

  [Constants.UPDATE_TRACK](action) {
    this.data = this.data.set('track', action.track);
  }

  [Constants.UPDATE_USER_ID](action) {
    this.data = this.data.set('user_id', action.userID);
  }

  [Constants.UPDATE_TIME](action) {
    this.data = this.data.set('time', action.time);
  }

  [Constants.UPDATE_RATING](action) {
    this.data = this.data.setIn(
      ['track', 'rating'], action.rating.get('rating')
    );
    this.data = this.data.setIn(
      ['track', 'rating_class'], action.rating.get('rating_class')
    );
  }

  [Constants.UPDATE_PLAYLIST](action) {
    this.data = this.data.set('playlist', action.playlist);
  }

  [Constants.REMOVE_PLAYLIST_TRACK](action) {
    this.data = this.data.deleteIn(['playlist', 'tracks', action.track.get('pos')]);
  }

  dispatcherCallback(action) {
    if (this[action.actionType]) {
      this[action.actionType].call(this, action);
      this.emitChange();
    }
  }

  currentState() {
    return this.data;
  }

  emitChange() {
    this.emit(CHANGE_EVENT);
  }

  addChangeListener(callback) {
    this.on(CHANGE_EVENT, callback);
  }

  removeChangeListener(callback) {
    this.removeListener(CHANGE_EVENT, callback);
  }

  reset() {
    this.data = defaultData;
  }
}

export default new Store(Dispatcher, defaultData);
