import Jukebox from './../../src/utils/jukebox';
import Actions from './../../src/actions/actions';
import Immutable from 'immutable';

describe('Jukebox', () => {
  let instance;

  describe('websocketServerURI', () => {
    beforeEach(() => {
      instance = new Jukebox();
    });
    it('returns the correct URI', () => {
      expect(instance.websocketServerURI()).toEqual(
        'ws://jukebox.local:8081'
      );
    })
  });

  describe('openConnection', () => {
    describe('when conn is ready', () => {
      it('does not create a new connection', () => {
        instance = new Jukebox();
        spyOn(instance, 'connectionReady').and.returnValue(true);
        spyOn(instance, 'websocketServerURI');
        instance.openConnection();
        expect(instance.websocketServerURI).not.toHaveBeenCalled();
      });
    })
    describe('when conn is not ready', () => {
      beforeEach(() => {
        instance = new Jukebox();
        spyOn(instance, 'connectionReady').and.returnValue(false);
      });
      it('creates a new connection using the websocketServerURI', () => {
        instance.openConnection();
        expect(instance.conn).toEqual(jasmine.any(WebSocket));
        expect(instance.conn.url).toEqual(instance.websocketServerURI());
      });

      it('sets up onmessage', () => {
        instance.openConnection();
        expect(instance.conn.onmessage).toEqual(instance.handleMessage);
      });

      it('sets up onclose', () => {
        instance.openConnection();
        expect(instance.conn.onclose).toEqual(instance.handleClose);
      });

      it('sets up onerror', () => {
        instance.openConnection();
        expect(instance.conn.onerror).toEqual(instance.handleError);
      });

      it('sets up onopen', () => {
        instance.openConnection();
        expect(instance.conn.onopen).toEqual(instance.handleOpen);
      });
    });
  });

  describe('connectionReady', () => {
    describe('when conn is undefined', () => {
      it('returns false', () => {
        instance = new Jukebox();
        expect(instance.connectionReady()).toBeFalsy();
      });
    });

    describe('when conn readyState is undefined', () => {
      it('returns false', () => {
        let conn = {}
        instance = new Jukebox(conn);
        expect(instance.connectionReady()).toBeFalsy();
      });
    });

    describe('when conn readyState is greater than 1', () => {
      it('returns false', () => {
        let conn = {readyState: 2}
        instance = new Jukebox(conn);
        expect(instance.connectionReady()).toBeFalsy();
      });
    });

    describe('when conn readyState is 0', () => {
      it('returns true', () => {
        let conn = {readyState: 0}
        instance = new Jukebox(conn);
        expect(instance.connectionReady()).toBeTruthy();
      });
    });

    describe('when conn readyState is 1', () => {
      it('returns true', () => {
        let conn = {readyState: 1}
        instance = new Jukebox(conn);
        expect(instance.connectionReady()).toBeTruthy();
      });
    });
  });

  describe('handleClose', () => {
    it('calls connectionClosed', () => {
      instance = new Jukebox();
      let message = '{"message":"message"}';
      spyOn(Actions, 'connectionClosed');
      instance.handleClose(message);
      expect(Actions.connectionClosed).toHaveBeenCalledWith(
        Immutable.fromJS(JSON.parse(message))
      );
    });
  });

  describe('handleError', () => {
    it('calls connectionError', () => {
      instance = new Jukebox();
      let message = '{"message":"message"}';
      spyOn(Actions, 'connectionError');
      instance.handleError(message);
      expect(Actions.connectionError).toHaveBeenCalledWith(
        Immutable.fromJS(JSON.parse(message))
      );
    });
  });

  describe('handleOpen', () => {
    it('calls connectionOpen', () => {
      instance = new Jukebox();
      spyOn(Actions, 'connectionOpen');
      instance.handleOpen();
      expect(Actions.connectionOpen).toHaveBeenCalledWith();
    });
  })

  describe('handleMessage', () => {
    let data, message
    beforeEach(() => {
      instance = new Jukebox();
      spyOn(Actions, 'updateTrack');
      spyOn(Actions, 'updateTime');
      spyOn(Actions, 'updateRating');
      spyOn(Actions, 'updatePlaylist');
      spyOn(Actions, 'updatePlayState');
      spyOn(Actions, 'updateVolume');
    });

    describe('when playState is present', () => {
      it('calls the updatePlayState action', () => {
        data = '{"state": "foo"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updatePlayState).toHaveBeenCalledWith('foo');
      });
    });

    describe('when track data is present', () => {
      it('calls the updateTrack action', () => {
        data = '{"track": "foo"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updateTrack).toHaveBeenCalledWith('foo');
      });
    });

    describe('when time data is present', () => {
      it('calls the updateTime action', () => {
        data = '{"time": "1"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updateTime).toHaveBeenCalledWith('1');
      });
    });

    describe('when rating data is present', () => {
      it('calls the updateRating action', () => {
        data = '{"rating": "1"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updateRating).toHaveBeenCalledWith('1');
      });
    });

    describe('when volume is present', () => {
      it('calls the updateVolume action', () => {
        data = '{"volume": "50"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updateVolume).toHaveBeenCalledWith('50');
      });
    });

    describe('when playlist data is present', () => {
      it('calls the updateRating action', () => {
        data = '{"playlist": "foo"}'
        message = {data: data}
        instance.handleMessage(message);
        expect(Actions.updatePlaylist).toHaveBeenCalledWith('foo');
      });
    });

    describe('when no data is present', () => {
      beforeEach(() => {
        message = {data: '{}'}
        instance.handleMessage(message);
      });
      it('does not call updateTrack', () => {
        expect(Actions.updateTrack).not.toHaveBeenCalled();
      });
      it('does not call updateTime', () => {
        expect(Actions.updateTime).not.toHaveBeenCalled();
      });
    })
  });

  describe('buildMessage', () => {
    let payload
    beforeEach(() => {
      instance = new Jukebox();
    });
    describe('when the user id is provided', () => {
      it('returns a payload with the user id included', () => {
        instance.userID = 1
        payload = instance.buildMessage('foo', 'bar')
        expect(payload).toEqual({ foo: 'bar', user_id: 1 })
      });
    });

    describe('when the user id and value are not provided', () => {
      it('returns a payload without the user id', () => {
        payload = instance.buildMessage('foo')
        expect(payload).toEqual({ foo: '' })
      });
    });
  });

  describe('sendMessage', () => {
    it('sends the payload', () => {
      let conn = jasmine.createSpyObj('conn', ['send'])
      instance = new Jukebox(conn);
      spyOn(instance, 'openConnection');
      let payload = { foo: 'bar', user_id: 1 }
      instance.sendMessage(payload);
      expect(conn.send).toHaveBeenCalledWith(JSON.stringify(payload));
      expect(instance.openConnection).toHaveBeenCalled();
    });
  });

  describe('vote', () => {
    it('calls sendMessage with the vote payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      let track = Immutable.fromJS({file: 'filename'});
      let state = 'state';
      instance.vote(track, state)
      expect(instance.sendMessage).toHaveBeenCalledWith({
        vote: {state: state, filename: 'filename'}
      })
    });
  });

  describe('setVolume', () => {
    it('calls sendMessage with the volume payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      let value = 50;
      instance.setVolume(value);
      expect(instance.sendMessage).toHaveBeenCalledWith({
        setvol: value
      });
    });
  });

  describe('play', () => {
    it('calls sendMessage with the play payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      instance.play();
      expect(instance.sendMessage).toHaveBeenCalledWith({
        play: ''
      });
    });
  });

  describe('pause', () => {
    it('calls sendMessage with the pause payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      instance.pause();
      expect(instance.sendMessage).toHaveBeenCalledWith({
        pause: ''
      });
    });
  });

  describe('next', () => {
    it('calls sendMessage with the next payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      instance.next();
      expect(instance.sendMessage).toHaveBeenCalledWith({
        next: ''
      });
    });
  });

  describe('previous', () => {
    it('calls sendMessage with the previous payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      instance.previous();
      expect(instance.sendMessage).toHaveBeenCalledWith({
        previous: ''
      });
    });
  });

  describe('bulkAdd', () => {
    it('calls sendMessage with the bulkAdd payload', () => {
      instance = new Jukebox();
      spyOn(instance, 'sendMessage');
      let tracks = ['foo', 'bar'];
      instance.bulkAdd(tracks);
      expect(instance.sendMessage).toHaveBeenCalledWith({
        bulk_add_to_playlist: { filenames: [ 'foo', 'bar' ] }
      });
    });
  });
});
