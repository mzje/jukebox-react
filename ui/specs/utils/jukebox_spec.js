import Jukebox from './../../src/utils/jukebox';
import Actions from './../../src/actions/actions';

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
      let message = 'message';
      spyOn(Actions, 'connectionClosed');
      instance.handleClose(message);
      expect(Actions.connectionClosed).toHaveBeenCalledWith(message);
    });
  });

  describe('handleError', () => {
    it('calls connectionError', () => {
      instance = new Jukebox();
      let message = 'message';
      spyOn(Actions, 'connectionError');
      instance.handleError(message);
      expect(Actions.connectionError).toHaveBeenCalledWith(message);
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
        payload = instance.buildMessage('foo', 'bar', '1')
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
    it('calls sendMessage with the payload', () => {
      spyOn(instance, 'sendMessage');
      let userID = '1';
      let track = {file: 'filename'};
      let state = 'state';
      instance.vote(userID, track, state)
      expect(instance.sendMessage).toHaveBeenCalledWith({
        vote: {state: state, filename: 'filename'},
        user_id: 1
      })
    });
  });
})
