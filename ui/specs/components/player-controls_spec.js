import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import PlayerControls from './../../src/components/player-controls';

describe('PlayerControls', () => {
  let instance;

  let Wrapper = React.createClass({
    render: function() {
      return (<div>{this.props.children}</div>);
    }
  });

  describe('pauseButton', () => {
    it('returns a pause button', () => {
      instance = new PlayerControls();
      let html = TestUtils.renderIntoDocument(
        <Wrapper>{instance.pauseButton()}</Wrapper>
      )
      let button = TestUtils.findRenderedDOMComponentWithTag(html, 'button');
      expect(button).toBeDefined();
    });
  });

  describe('playOrPauseButton', () => {
    beforeEach(() => {
      instance = new PlayerControls();
      spyOn(instance, 'pauseButton');
      spyOn(instance, 'playButton');
    });
    describe('when play state is play', () => {
      it('returns the pause button', () => {
        instance.playOrPauseButton('play');
        expect(instance.pauseButton).toHaveBeenCalled();
        expect(instance.playButton).not.toHaveBeenCalled();
      });
    });

    describe('when play state is not play', () => {
      it('returns the play button', () => {
        instance.playOrPauseButton('foo');
        expect(instance.pauseButton).not.toHaveBeenCalled();
        expect(instance.playButton).toHaveBeenCalled();
      });
    });
  });
});
