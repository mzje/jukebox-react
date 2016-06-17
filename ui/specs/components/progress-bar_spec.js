import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import ProgressBar from './../../src/components/progress-bar';
import TrackTime from './../../src/components/track-time';

describe('ProgressBar', () => {
  let instance;

  describe('duration_to_seconds', () => {
    it('converts duration to seconds', () => {
      instance = new ProgressBar({duration: '02:00'});
      expect(instance.duration_to_seconds()).toEqual(120);
    });
  });

  describe('percentage_played', () => {
    it('returns the time / duration', () => {
      instance = new ProgressBar({duration: '02:00', time: 60});
      expect(instance.percentage_played()).toEqual(50);
    });
  });

  describe('render', () => {
    it('renders the progress bar with the correct width', () => {
      instance = TestUtils.renderIntoDocument(<ProgressBar time={60} duration={'03:00'} />);
      let progressBar = TestUtils.findRenderedDOMComponentWithClass(instance, 'progressBarContent');
      expect(progressBar).toBeDefined();
      expect(progressBar.style.width).toEqual('33%');
    });
  });
});
