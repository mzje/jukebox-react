import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Ui from './../../js/views/ui';

describe('Ui', () => {
  let instance;

  // describe('nowPlayingHTML', () => {
  //   beforeEach(() => {
  //     instance = new Ui();
  //   });
  //   it('returns an instance of the NowPlaying component', () => {
  //     let track = 'foo'
  //     let nowPlayingComponent = TestUtils.renderIntoDocument(
  //       instance.nowPlayingHTML(track)
  //     )
  //     expect(nowPlayingComponent).toBeDefined();
  //     expect(nowPlayingComponent.props.track).toEqual(track);
  //   })
  // });

  describe('render', () => {
    beforeEach(() => {
      instance = new Ui()
      instance.state.store = {track:'the track', user_id: '1'}
      spyOn(instance, 'sidePanelHTML');
    });
    it('calls sidePanelHTML', () => {
      instance.render();
      expect(instance.sidePanelHTML).toHaveBeenCalledWith('the track', '1');
    })

    // it('calls nowPlayingHTML', () => {
    //   instance.render();
    //   expect(instance.nowPlayingHTML).toHaveBeenCalledWith('the track');
    // });
    // it('calls voteHTML', () => {
    //   instance.render();
    //   expect(instance.voteHTML).toHaveBeenCalledWith('the track', '1');
    // });
  });
});
