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
          volume: null,
          playState: null,
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

  describe('UPDATE_VOLUME', () => {
    it('updates the volume', () => {
      action = {volume: '1'}
      instance[Constants.UPDATE_VOLUME](action)
      expect(instance.currentState().get('volume')).toEqual('1');
    });
  });

  describe('UPDATE_PLAYSTATE', () => {
    it('updates the playState', () => {
      action = {playState: '1'}
      instance[Constants.UPDATE_PLAYSTATE](action)
      expect(instance.currentState().get('playState')).toEqual('1');
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

  describe('UPDATE_RATING', () => {
    it('updates the rating and rating_class', () => {
      instance[Constants.UPDATE_TRACK]({track:Immutable.fromJS({})})
      action = {rating: Immutable.fromJS({rating: '1', rating_class:'foo'})}
      instance[Constants.UPDATE_RATING](action)
      expect(instance.currentState().getIn(['track', 'rating'])).toEqual('1');
      expect(instance.currentState().getIn(['track', 'rating_class'])).toEqual('foo');
    });
  });

  describe('UPDATE_PLAYLIST', () => {
    it('updates the playlist', () => {
      action = {playlist: 'foo'}
      instance[Constants.UPDATE_PLAYLIST](action)
      expect(instance.currentState().get('playlist')).toEqual('foo');
    });
  });

  describe('REMOVE_PLAYLIST_TRACK', () => {
    it('removes the track from the playlist', () => {
      let playlist = Immutable.fromJS({
        tracks: Immutable.fromJS({0: 'foo', 1: 'bar'})
      });
      instance.data = instance.data.set('playlist', playlist);
      action = {track:Immutable.fromJS({pos: '1'})};
      instance[Constants.REMOVE_PLAYLIST_TRACK](action);
      expect(instance.currentState().getIn(['playlist', 'tracks']).toJS()).toEqual(
        { "0": "foo" }
      );
    })
  });

  describe('reset', () => {
    it('resets the data', () => {
      instance[Constants.UPDATE_TRACK]({track: 'foo'})
      instance.reset();
      expect(instance.currentState()).toEqual(
        Immutable.fromJS({
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
        })
      );
    });
  });
});
