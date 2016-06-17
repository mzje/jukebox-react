import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Vote from './../../src/components/vote';
import Ui from './../../src/views/ui/ui';

describe('Vote', () => {
  let instance;

  let jukebox = {
    vote: function() {}
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

  describe('voteUp', () => {
    it('prevents the default event and calls vote on the jukebox', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <Vote track={'the track'} userId={'5'} />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, Vote);
      spyOn(instance.context.jukebox, 'vote')
      let event = jasmine.createSpyObj('event', ['preventDefault']);
      instance.voteUp(event);
      expect(instance.context.jukebox.vote).toHaveBeenCalledWith('5', 'the track', 1);
    });
  });

  describe('voteHTML', () => {
    it('returns a link to register an upvote', () => {
      instance = new Vote()
      spyOn(instance, 'voteUp');
      let voteHTML = TestUtils.renderIntoDocument(
        <Wrapper>
          { instance.voteHTML() }
        </Wrapper>
      );
      let link = TestUtils.findRenderedDOMComponentWithTag(voteHTML, 'a');
      TestUtils.Simulate.click(link)
      expect(instance.voteUp).toHaveBeenCalled();
    });
  });

  describe('render', () => {
    describe('when track and userId', () => {
      it('calls voteHTML', () => {
        instance = TestUtils.renderIntoDocument(
          <Vote track={'track'} userId={'1'} />
        );
        spyOn(instance, 'voteHTML')
        instance.render()
        expect(instance.voteHTML).toHaveBeenCalled();
      });
    });

    describe('when track but not userId', () => {
      it('does not call voteHTML', () => {
        instance = TestUtils.renderIntoDocument(
          <Vote track={'track'} />
        );
        spyOn(instance, 'voteHTML')
        instance.render()
        expect(instance.voteHTML).not.toHaveBeenCalled();
      });
    });

    describe('when userId but not track', () => {
      it('does not call voteHTML', () => {
        instance = TestUtils.renderIntoDocument(
          <Vote userId={'1'} />
        );
        spyOn(instance, 'voteHTML')
        instance.render()
        expect(instance.voteHTML).not.toHaveBeenCalled();
      });
    });
  })
});
