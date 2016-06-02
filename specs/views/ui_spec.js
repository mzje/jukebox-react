import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Ui from './../../js/views/ui';

describe('Ui', () => {
  let instance;
  describe('render', () => {
    beforeEach(() => {
      instance = new Ui()
      instance.state.storeData = instance.state.storeData.set('track', 'the track')
      instance.state.storeData = instance.state.storeData.set('user_id', '1')
      spyOn(instance, 'sidePanelHTML');
    });
    it('calls sidePanelHTML', () => {
      instance.render();
      expect(instance.sidePanelHTML).toHaveBeenCalledWith('the track', '1');
    });
  });
});
