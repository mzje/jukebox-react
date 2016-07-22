import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Ui from './../../../src/views/common/ui';
import SidePanel from './../../../src/views/common/side-panel';
import Immutable from 'immutable';

describe('Ui', () => {
  let instance;

  describe('getChildContext', () => {
    it('returns the jukebox', () => {
      instance = new Ui()
      expect(instance.getChildContext()).toEqual(
        { jukebox: instance.state.jukebox }
      )
    })
  })

  describe('componentDidMount', () => {
    let store, jukebox
    beforeEach(() => {
      instance = new Ui();
      store = jasmine.createSpyObj('store', ['addChangeListener']);
      jukebox = jasmine.createSpyObj('jukebox', ['openConnection']);
      instance.state.store = store;
      instance.state.jukebox = jukebox;
      instance.componentDidMount();
    });
    it('adds a change listener', () => {
      expect(store.addChangeListener).toHaveBeenCalledWith(instance._onChange);
    });
    it('calls openConnection on jukebox', () => {
      expect(jukebox.openConnection).toHaveBeenCalled();
    });
  });

  describe('componentWillUnmount', () => {
    let store
    beforeEach(() => {
      instance = new Ui();
      store = jasmine.createSpyObj('store', ['removeChangeListener']);
      instance.state.store = store;
      instance.componentWillUnmount();
    });
    it('calls removeChangeListener', () => {
      expect(store.removeChangeListener).toHaveBeenCalledWith(instance._onChange);
    })
  })

  describe('sidePanelHTML', () => {
    it('renders a SidePanel component', () => {
      instance = new Ui();
      let track = Immutable.fromJS({});
      let panelHTML = TestUtils.renderIntoDocument(
        instance.sidePanelHTML(track)
      );
      let sidePanel = TestUtils.findRenderedComponentWithType(panelHTML, SidePanel)
      expect(sidePanel.props.track).toEqual(track);
    });
  });

  describe('_onChange', () => {
    it('calls setState', () => {
      instance = new Ui();
      spyOn(instance, 'setState');
      let store = { currentState: function() { return 'current state' } }
      instance.state.store = store;
      instance._onChange();
      expect(instance.setState).toHaveBeenCalledWith({ storeData: 'current state' });
    });
  });

  describe('render', () => {
    let div, event
    beforeEach(() => {
      instance =  TestUtils.renderIntoDocument(<Ui />);
      instance.state.storeData = instance.state.storeData.set('track', 'the track')
      instance.state.storeData = instance.state.storeData.set('time', 123)
      instance.state.storeData = instance.state.storeData.set('volume', 10)
      instance.state.storeData = instance.state.storeData.set('playState', 'play state')
      spyOn(instance, 'sidePanelHTML');
      instance.render();
    });
    it('calls sidePanelHTML', () => {
      expect(instance.sidePanelHTML).toHaveBeenCalledWith(
        'the track', 123, 10, 'play state'
      );
    });
    describe('the ui-container', () => {
      beforeEach(() => {
        div = TestUtils.findRenderedDOMComponentWithClass(
          instance, 'ui-container'
        );
        expect(div).toBeDefined();
        event = {
          preventDefault: function () {},
          stopPropagation: function () {},
          dataTransfer: {
            getData: function (type) {
              if (type == 'text/plain') {
                return 'https://open.spotify.com/track/7leW7LFEA1YN17GAlHqSKQ\nhttps://open.spotify.com/track/0syDLgKCSeMBq8sboBULQf\nfoo:bar'
              }
            }
          }
        };
        spyOn(event, 'preventDefault')
        spyOn(event, 'stopPropagation')
      });
      it('renders a ui-container div with drag enter', () => {
        TestUtils.Simulate.dragEnter(div, event)
        expect(event.preventDefault).toHaveBeenCalled()
        expect(event.stopPropagation).toHaveBeenCalled()
      });
      it('sets up the div with drag over event', () => {
        TestUtils.Simulate.dragOver(div, event)
        expect(event.preventDefault).toHaveBeenCalled()
        expect(event.stopPropagation).toHaveBeenCalled()
      });
      it('sets up the div with drag leave event', () => {
        TestUtils.Simulate.dragLeave(div, event)
        expect(event.preventDefault).toHaveBeenCalled()
        expect(event.stopPropagation).toHaveBeenCalled()
      });
      it('allows spotify tracks to be dropped on the div & sent to jukebox bulkAdd', () => {
        spyOn(instance.state.jukebox, 'bulkAdd')
        TestUtils.Simulate.drop(div, event)
        expect(event.preventDefault).toHaveBeenCalled()
        expect(event.stopPropagation).toHaveBeenCalled()
        expect(instance.state.jukebox.bulkAdd).toHaveBeenCalledWith(
          [
            'spotify:track:7leW7LFEA1YN17GAlHqSKQ',
            'spotify:track:0syDLgKCSeMBq8sboBULQf'
          ]
        )
      });
    })
  });
});
