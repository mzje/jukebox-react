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

  describe('updateVolume', () => {
    it('dispatches UPDATE_VOLUME with the volume', () => {
      let volume = '50';
      Actions.updateVolume(volume)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_VOLUME,
          volume: volume
        }
      );
    });
  });

  describe('updatePlayState', () => {
    it('dispatches UPDATE_PLAYSTATE with the playState', () => {
      let playState = 'foo';
      Actions.updatePlayState(playState)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_PLAYSTATE,
          playState: playState
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

  describe('updateRating', () => {
    it('dispatches UPDATE_RATING with the rating', () => {
      let rating = '5';
      Actions.updateRating(rating)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_RATING,
          rating: rating
        }
      );
    });
  });

  describe('updatePlaylist', () => {
    it('dispatches UPDATE_PLAYLIST with the playlist', () => {
      let playlist = 'playlist';
      Actions.updatePlaylist(playlist)
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.UPDATE_PLAYLIST,
          playlist: playlist
        }
      );
    });
  });

  describe('removePlaylistTrack', () => {
    it('dispatches REMOVE_PLAYLIST_TRACK with the track', () => {
      let track = 'track';
      Actions.removePlaylistTrack(track);
      expect(Dispatcher.dispatch).toHaveBeenCalledWith(
        {
          actionType: Constants.REMOVE_PLAYLIST_TRACK,
          track: 'track'
        }
      );
    });
  });
})
