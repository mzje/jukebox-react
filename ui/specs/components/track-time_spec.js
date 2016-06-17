import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import TrackTime from './../../src/components/track-time';
import ProgressBar from './../../src/components/progress-bar';

describe('TrackTime', () => {
  let instance;

  let Wrapper = React.createClass({
    render: function() {
      return (<div>{this.props.children}</div>);
    }
  });

  describe('contentHTML', () => {
    beforeEach(() => {
      instance = new TrackTime({time:1})
      spyOn(instance, 'currentTimeHTML');
    });
    describe('when there is a time and a duration', () => {
      it('returns the time and progress bar', () => {
        instance.contentHTML('05:40', 2);
        expect(instance.currentTimeHTML).toHaveBeenCalledWith('05:40', 2)
      });
      it('returns a ProgressBar instance', () => {
        let html = TestUtils.renderIntoDocument(
          <Wrapper>
            { instance.contentHTML('05:40', 2) }
          </Wrapper>
        );
        let progressBarInstance = TestUtils.findRenderedComponentWithType(html, ProgressBar)
        expect(progressBarInstance).toBeDefined();
        expect(progressBarInstance.props.time).toEqual(2);
        expect(progressBarInstance.props.duration).toEqual('05:40');
      });
    });
    describe('when there is not time or duration', () => {
      it('returns null', () => {
        expect(instance.contentHTML()).toEqual(null);
      });
    });
  });

  describe('currentTimeHTML', () => {
    it('returns the time and the total duration', () => {
      instance = new TrackTime({time:1});
      let html = TestUtils.renderIntoDocument(
        instance.currentTimeHTML("02:30", 100)
      );
      expect(html.textContent).toContain("02:30");
      expect(html.textContent).toContain("01:40");
    });
  });

  describe('seconds_to_time', () => {
    it('converts seconds to time', () => {
      instance = new TrackTime({time:1})
      expect(instance.secondsToTime(120)).toEqual('02:00')
    });
  });

  describe('tick', () => {
    describe('when the time prop is set', () => {
      beforeEach(() => {
        instance = new TrackTime({time:1})
      });
      it('increments the state by 1', () => {
        spyOn(instance, 'setState');
        instance.tick();
        expect(instance.setState).toHaveBeenCalledWith({time:2})
      });
    });

    describe('when the time prop is not set', () => {
      beforeEach(() => {
        instance = new TrackTime({time:null})
      });
      it('does not increment the state by 1', () => {
        spyOn(instance, 'setState');
        instance.tick();
        expect(instance.setState).not.toHaveBeenCalled();
      });
    });
  });

  describe('componentWillReceiveProps', () => {
    it('calls sync time with next props time', () => {
      instance = new TrackTime({time:1});
      spyOn(instance, 'syncTime');
      let nextProps = {time:2}
      instance.componentWillReceiveProps(nextProps);
      expect(instance.syncTime).toHaveBeenCalledWith(2);
    });
  });

  describe('syncTime', () => {
    describe('when time prop is different to the new time', () => {
      it('sets the time', () => {
        instance = new TrackTime({time:1});
        spyOn(instance, 'setState');
        instance.syncTime(3)
        expect(instance.setState).toHaveBeenCalledWith({time:3})
      });
    });
    describe('when time prop is the same as the new time', () => {
      it('does not set the time', () => {
        instance = new TrackTime({time:1});
        spyOn(instance, 'setState');
        instance.syncTime(1)
        expect(instance.setState).not.toHaveBeenCalled();
      });
    });
  });
});
