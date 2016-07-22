import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import PlayerControls from './../../src/components/player-controls';

describe('PlayerControls', () => {
  let instance;

  let jukebox = {
    play: function() {},
    pause: function() {},
    next: function() {},
    previous: function() {}
  }

  let Wrapper = React.createClass({
    childContextTypes: {
      jukebox: React.PropTypes.object
    },
    getChildContext: function() {
      return {
        jukebox: jukebox
      }
    },
    render: function() {
      return (<div>{this.props.children}</div>);
    }
  });

  describe('pauseButton', () => {
    it('returns a pause button', () => {
      instance = new PlayerControls();
      spyOn(instance, 'pause');
      let html = TestUtils.renderIntoDocument(
        <Wrapper>{instance.pauseButton()}</Wrapper>
      )
      let button = TestUtils.findRenderedDOMComponentWithTag(html, 'button');
      expect(button).toBeDefined();
      TestUtils.Simulate.click(button);
      expect(instance.pause).toHaveBeenCalled();
    });
  });

  describe('playButton', () => {
    it('returns a play button', () => {
      instance = new PlayerControls();
      spyOn(instance, 'play');
      let html = TestUtils.renderIntoDocument(
        <Wrapper>{instance.playButton()}</Wrapper>
      )
      let button = TestUtils.findRenderedDOMComponentWithTag(html, 'button');
      expect(button).toBeDefined();
      TestUtils.Simulate.click(button);
      expect(instance.play).toHaveBeenCalled();
    });
  });

  describe('play', () => {
    it('calls play on the jukebox', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <PlayerControls />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, PlayerControls);
      spyOn(instance.context.jukebox, 'play')
      instance.play();
      expect(instance.context.jukebox.play).toHaveBeenCalled();
    });
  });

  describe('pause', () => {
    it('calls pause on the jukebox', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <PlayerControls />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, PlayerControls);
      spyOn(instance.context.jukebox, 'pause')
      instance.pause();
      expect(instance.context.jukebox.pause).toHaveBeenCalled();
    });
  });

  describe('next', () => {
    it('calls next on the jukebox', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <PlayerControls />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, PlayerControls);
      spyOn(instance.context.jukebox, 'next')
      instance.next();
      expect(instance.context.jukebox.next).toHaveBeenCalled();
    });
  });

  describe('previous', () => {
    it('calls previous on the jukebox', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <PlayerControls />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, PlayerControls);
      spyOn(instance.context.jukebox, 'previous')
      instance.previous();
      expect(instance.context.jukebox.previous).toHaveBeenCalled();
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
