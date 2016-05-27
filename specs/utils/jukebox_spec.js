import Jukebox from './../../js/utils/jukebox';
import Actions from './../../js/actions/actions';

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

  describe('handleMessage', () => {
    let data, message
    beforeEach(() => {
      instance = new Jukebox();
    });
    describe('when track data is present', () => {
      it('calls the updateTrack action', () => {
        data = '{"track": "foo"}'
        message = {data: data}
        spyOn(Actions, 'updateTrack')
        instance.handleMessage(message);
        expect(Actions.updateTrack).toHaveBeenCalledWith('foo');
      });
    });
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
})
