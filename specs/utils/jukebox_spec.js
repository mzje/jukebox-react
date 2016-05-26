import Jukebox from './../../js/utils/jukebox';

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
})
