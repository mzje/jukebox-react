import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import NowPlaying from './../../js/components/now-playing';

describe('NowPlaying', () => {
  let instance;

  describe('contentHTML', () => {
    beforeEach(() => {
      instance = new NowPlaying();
      spyOn(instance, 'trackInfoHTML');
      spyOn(instance, 'loadingHTML');
    })
    describe('when there is a track', () => {
      it('calls trackInfoHTML', () => {
        let track = {title: 'foo', artist: 'bar'}
        instance.contentHTML(track);
        expect(instance.trackInfoHTML).toHaveBeenCalledWith('foo', 'bar');
        expect(instance.loadingHTML).not.toHaveBeenCalled();
      });
    });

    describe('when there is not a track', () => {
      it('calls loadingHTML', () => {
        instance.contentHTML();
        expect(instance.trackInfoHTML).not.toHaveBeenCalled();
        expect(instance.loadingHTML).toHaveBeenCalled();
      });
    });
  });

  describe('trackInfoHTML', () => {
    it('returns the artist name and track title', () => {
      instance = new NowPlaying();
      let html = TestUtils.renderIntoDocument(instance.trackInfoHTML(
        'British Sea Power', 'Chasing Flags'
      ))
      expect(html.textContent).toEqual("British Sea Power'Chasing Flags'");
    });
  });

  describe('loadingHTML', () => {
    it('returns the loading content', () => {
      instance = new NowPlaying();
      let html = TestUtils.renderIntoDocument(instance.loadingHTML());
      expect(html.textContent).toEqual("Loading...");
    });
  })

  describe('render', () => {
    beforeEach(() => {
      instance = new NowPlaying({track: 'track'})
      spyOn(instance, 'contentHTML');
    });
    it('calls conentHTML', () => {
      instance.render();
      expect(instance.contentHTML).toHaveBeenCalledWith('track');
    });
  });
});
