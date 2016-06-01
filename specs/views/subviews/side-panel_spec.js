import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import SidePanel from './../../../js/views/subviews/side-panel';

describe('SidePanel', () => {
  let instance;

  describe('nowPlayingHTML', () => {
    beforeEach(() => {
      instance = new SidePanel();
    });
    it('returns an instance of the NowPlaying component', () => {
      let track = 'foo'
      let nowPlayingComponent = TestUtils.renderIntoDocument(
        instance.nowPlayingHTML(track)
      )
      expect(nowPlayingComponent).toBeDefined();
      expect(nowPlayingComponent.props.track).toEqual(track);
    })
  });

  describe('render', () => {
    beforeEach(() => {
      instance = new SidePanel({track:'the track', userId: '1'})
      spyOn(instance, 'nowPlayingHTML');
      spyOn(instance, 'voteHTML');
    });
    it('calls nowPlayingHTML', () => {
      instance.render();
      expect(instance.nowPlayingHTML).toHaveBeenCalledWith('the track');
    });
    it('calls voteHTML', () => {
      instance.render();
      expect(instance.voteHTML).toHaveBeenCalledWith('the track', '1');
    });
  });
});
