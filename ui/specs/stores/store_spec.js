import Store from './../../src/stores/store';
import Constants from './../../src/constants/constants'
import Dispatcher from './../../src/dispatcher/dispatcher'
import Immutable from 'immutable'

describe('Store', () => {
  let instance, action;

  beforeEach(() => {
    instance = Store
  });

  afterEach(() => {
    instance.reset();
  })

  describe('currentState', () => {
    it('returns the data', () => {
      expect(instance.currentState()).toEqual(
        Immutable.fromJS({
          track: null,
          user_id: null,
          time: null,
          playlist: null,
          connection: {
            open: false,
            error_message: null,
            closed_message: null
          }
        })
      );
    });
  });

  describe('emitChange', () => {
    it('calls emit with the CHANGE_EVENT', () => {
      spyOn(instance, 'emit');
      instance.emitChange();
      expect(instance.emit).toHaveBeenCalledWith('change');
    });
  });

  describe('dispatcherCallback', () => {
    beforeEach(() => {
      spyOn(instance, 'emitChange');
    });
    describe('when the action type is unknown', () => {
      it('does not call emit change', () => {
        instance.dispatcherCallback({actionType: 'unknown'});
        expect(instance.emitChange).not.toHaveBeenCalled();
      })
    });
    describe('when the action type is known', () => {
      beforeEach(() => {
        instance.testAction = jasmine.createSpy('testAction');
        instance.dispatcherCallback({actionType: 'testAction'});
      });
      it('calls the action', () => {
        expect(instance.testAction).toHaveBeenCalled();
      })
      it('calls emitChange', () => {
        expect(instance.emitChange).toHaveBeenCalled();
      })
    });
  });

  describe('addChangeListener', () => {
    it('calls on with CHANGE_EVENT and the callback', () => {
      let callback = jasmine.createSpy('callback');
      spyOn(instance, 'on');
      instance.addChangeListener(callback);
      expect(instance.on).toHaveBeenCalledWith('change', callback)
    });
  });

  describe('removeChangeListener', () => {
    it('calls removeListener with CHANGE_EVENT and the callback', () => {
      let callback = jasmine.createSpy('callback');
      spyOn(instance, 'removeListener');
      instance.removeChangeListener(callback);
      expect(instance.removeListener).toHaveBeenCalledWith('change', callback)
    });
  });

  describe('CONNECTION_OPEN', () => {
    it('sets connection open to true', () => {
      instance[Constants.CONNECTION_OPEN]()
      expect(
        instance.currentState().getIn(['connection', 'open'])
      ).toBeTruthy();
    })
  });

  describe('CONNECTION_ERROR', () => {
    it('sets connection error_message', () => {
      let action = {message: 'some error'}
      instance[Constants.CONNECTION_ERROR](action)
      expect(
        instance.currentState().getIn(['connection', 'error_message'])
      ).toEqual('some error');
    })
  });

  describe('CONNECTION_CLOSED', () => {
    it('sets connection open to false amd closed_message', () => {
      let action = {message: 'some message'}
      instance[Constants.CONNECTION_CLOSED](action)
      expect(
        instance.currentState().getIn(['connection', 'closed_message'])
      ).toEqual('some message');
      expect(
        instance.currentState().getIn(['connection', 'open'])
      ).toBeFalsy();
    })
  });

  describe('UPDATE_TRACK', () => {
    it('updates the track data', () => {
      action = {track: 'foo'}
      instance[Constants.UPDATE_TRACK](action)
      expect(instance.currentState().get('track')).toEqual('foo');
    });
  });

  describe('UPDATE_USER_ID', () => {
    it('updates the user id', () => {
      action = {userID: '1'}
      instance[Constants.UPDATE_USER_ID](action)
      expect(instance.currentState().get('user_id')).toEqual('1');
    });
  });

  describe('UPDATE_TIME', () => {
    it('updates the time', () => {
      action = {time: '1'}
      instance[Constants.UPDATE_TIME](action)
      expect(instance.currentState().get('time')).toEqual('1');
    });
  });

  describe('reset', () => {
    it('resets the data', () => {
      instance[Constants.UPDATE_TRACK]({track: 'foo'})
      instance.reset();
      expect(instance.currentState()).toEqual(
        Immutable.fromJS({
          track: null,
          user_id: null,
          time: null,
          playlist: null,
          connection: {
            open: false,
            error_message: null,
            closed_message: null
          }
        })
      );
    });
  });
});
