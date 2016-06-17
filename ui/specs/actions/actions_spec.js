import Actions from './../../src/actions/actions';
import Constants from './../../src/constants/constants'
import Dispatcher from './../../src/dispatcher/dispatcher'

describe('Actions', () => {
  beforeEach(() => {
    spyOn(Dispatcher, 'dispatch');
  });

  describe('connectionOpen', () => {
    it('dispatches CONNECTION_OPEN', () => {
      Actions.connectionOpen();
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.CONNECTION_OPEN
        }
      )
    });
  });

  describe('connectionError', () => {
    it('dispatches CONNECTION_OPEN with the message', () => {
      let message = 'message'
      Actions.connectionError(message);
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.CONNECTION_ERROR,
          message: message
        }
      )
    });
  });

  describe('connectionClosed', () => {
    it('dispatches CONNECTION_CLOSED with the message', () => {
      let message = 'message'
      Actions.connectionClosed(message);
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.CONNECTION_CLOSED,
          message: message
        }
      )
    });
  });

  describe('updateTrack', () => {
    it('dispatches UPDATE_TRACK with the track', () => {
      let track = 'foo';
      Actions.updateTrack(track)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_TRACK,
          track: track
        }
      );
    });
  });

  describe('updateUserID', () => {
    it('dispatches UPDATE_USER_ID with the track', () => {
      let userID = '1';
      Actions.updateUserID(userID)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_USER_ID,
          userID: userID
        }
      );
    });
  });

  describe('updateTime', () => {
    it('dispatches UPDATE_TIME with the track', () => {
      let time = '1';
      Actions.updateTime(time)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_TIME,
          time: time
        }
      );
    });
  });
})
