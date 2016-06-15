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
        let track = { title: 'foo', 
                      artist: 'bar',
                      filename: 'spotify:track:example',
                      artwork_url: 'https://artworkurl.com',
                      added_by: 'username',
                      duration: '01:55'
                    }
        let time = 123
        instance.contentHTML(track, time);
        expect(instance.trackInfoHTML).toHaveBeenCalledWith('spotify:track:example', 'foo', 'bar', 'https://artworkurl.com', 'username', '01:55', 123);
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
    instance = new NowPlaying();
    let html = TestUtils.renderIntoDocument(instance.trackInfoHTML(
      'spotify:track:example', 'British Sea Power', 'Chasing Flags', 'https://artworkurl.com', 'username', '01:23', '45'
    ))
    it('returns the artist name and track title', () => {
      expect(html.textContent).toContain("British Sea Power'Chasing Flags'");
    });
    it('returns the track duration', () => {
      expect(html.textContent).toContain('01:23');
    });
    it('returns the track chosen by', () => {
      expect(html.textContent).toContain('Chosen by username');
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
    it('calls contentHTML', () => {
      instance.render();
      expect(instance.contentHTML).toHaveBeenCalledWith('track', undefined);
    });
  });
});
