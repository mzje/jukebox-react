import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Volume from './../../src/components/volume';
import Ui from './../../src/views/common/ui';

describe('Volume', () => {
  let instance;

  let jukebox = {
    setVolume: function() {}
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

  describe('componentWillReceiveProps', () => {
    describe('when next props volume is not null', () => {
      it('sets the state volume', () => {
        instance = new Volume({volume:1});
        let nextProps = {volume: 50};
        instance.componentWillReceiveProps(nextProps);
        expect(instance.state.volume).toEqual(50);
      });
    });

    describe('when next props volume is null', () => {
      it('does not set the state volume', () => {
        instance = new Volume({volume:1});
        let nextProps = {};
        instance.componentWillReceiveProps(nextProps);
        expect(instance.state.volume).toEqual(1);
      });
    });
  });

  describe('updateVolume', () => {
    it('calls setVolume on the jukebox context', () => {
      let ui = TestUtils.renderIntoDocument(
        <Wrapper>
          <Volume volume={'1'} userId={'1'} />
        </Wrapper>
      );
      instance = TestUtils.findRenderedComponentWithType(ui, Volume);
      spyOn(instance.context.jukebox, 'setVolume');
      let event = { target: { value: 50 } }
      instance.updateVolume(event);
      expect(instance.context.jukebox.setVolume).toHaveBeenCalledWith(
        '1', 50
      );
    });
  });

  describe('updateSlider', () => {
    it('sets the volume state', () => {
      instance = new Volume({volume: 1});
      spyOn(instance, 'setState');
      let event = { target: { value: 50 } }
      instance.updateSlider(event);
      expect(instance.setState).toHaveBeenCalledWith(
        { volume: 50 }
      );
    });
  });

  describe('contentHTML', () => {
    it('renders an input of type range', () => {
      instance = new Volume({volume: null});
      spyOn(instance, 'updateSlider');
      spyOn(instance, 'updateVolume');
      let html = TestUtils.renderIntoDocument(
        <Wrapper>
          {instance.contentHTML()}
        </Wrapper>
      );
      let input = TestUtils.findRenderedDOMComponentWithTag(html, 'input');
      expect(input).toBeDefined();
      expect(input.value).toEqual('0');
      expect(input.type).toEqual('range');
      expect(input.min).toEqual('0');
      expect(input.max).toEqual('100');
      TestUtils.Simulate.change(input);
      expect(instance.updateSlider).toHaveBeenCalled();
      TestUtils.Simulate.mouseDown(input);
      TestUtils.Simulate.mouseUp(input);
      expect(instance.updateVolume).toHaveBeenCalled();
    });
  })

  describe('render', () => {
    it('calls contentHTML with the volume', () => {
      instance = TestUtils.renderIntoDocument(
        <Volume volume={'2'} userId={'1'} />
      );
      spyOn(instance, 'contentHTML');
      instance.render();
      expect(instance.contentHTML).toHaveBeenCalledWith('2')
    })
  });
});
