import Dispatcher from '../dispatcher/dispatcher';
import { EventEmitter } from 'events'
import Constants from '../constants/constants';
import Immutable from 'immutable';

var CHANGE_EVENT = 'change';

var defaultData = Immutable.fromJS({
  track: null,
  user_id: null
});

class Store extends EventEmitter {

  constructor(Dispatcher, defaultData) {
    super(Dispatcher, defaultData)
    this.dispatchToken = Dispatcher.register(this.dispatcherCallback.bind(this));
    this.data = defaultData;
  }

  [Constants.UPDATE_TRACK](action) {
    this.data = this.data.set('track', action.track)
  }

  [Constants.UPDATE_USER_ID](action) {
    this.data = this.data.set('user_id', action.userID)
  }

  dispatcherCallback(action) {
    if(this[action.actionType]) {
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

  /**
   * @param {function} callback
   */
  addChangeListener(callback) {
    this.on(CHANGE_EVENT, callback);
  }

  /**
   * @param {function} callback
   */
  removeChangeListener(callback) {
    this.removeListener(CHANGE_EVENT, callback);
  }

  reset() {
    this.data = defaultData;
  }
};

export default new Store(Dispatcher, defaultData)
