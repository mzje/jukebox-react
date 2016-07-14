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
    beforeEach(() => {
      instance =  TestUtils.renderIntoDocument(<Ui />);
      instance.state.storeData = instance.state.storeData.set('track', 'the track')
      instance.state.storeData = instance.state.storeData.set('time', 123)
      instance.state.storeData = instance.state.storeData.set('volume', 10)
      instance.state.storeData = instance.state.storeData.set('playState', 'play state')
      spyOn(instance, 'sidePanelHTML');
    });
    it('calls sidePanelHTML', () => {
      instance.render();
      expect(instance.sidePanelHTML).toHaveBeenCalledWith(
        'the track', 123, 10, 'play state'
      );
    });
  });
});
