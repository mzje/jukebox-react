import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Ui from './../../js/views/ui';
import Actions from './../../js/actions/actions';
import SidePanel from './../../js/views/subviews/side-panel';

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
      instance._onChange = { bind: function(value) {return 'foo'} };
      instance.state.store = store;
      instance.state.jukebox = jukebox;
      instance.componentDidMount();
    });
    it('adds a change listener', () => {
      expect(store.addChangeListener).toHaveBeenCalledWith('foo');
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
      instance._onChange = { bind: function(value) {return 'foo'} };
      instance.state.store = store;
      instance.componentWillUnmount();
    });
    it('calls removeChangeListener', () => {
      expect(store.removeChangeListener).toHaveBeenCalledWith('foo');
    })
  })

  describe('sidePanelHTML', () => {
    it('renders a SidePanel component', () => {
      instance = new Ui();
      let track = 'track';
      let userId = 'userId'
      let panelHTML = TestUtils.renderIntoDocument(
        instance.sidePanelHTML(track, userId)
      );
      let sidePanel = TestUtils.findRenderedComponentWithType(panelHTML, SidePanel)
      expect(sidePanel.props.track).toEqual(track);
      expect(sidePanel.props.userId).toEqual(userId);
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

  describe('updateUserID', () => {
    it('calls Actions.updateUserID with the target value', () => {
      instance = new Ui()
      spyOn(Actions, 'updateUserID')
      let onChangeEvent = { target: {value: '1'} }
      instance.updateUserID(onChangeEvent);
      expect(Actions.updateUserID).toHaveBeenCalledWith(onChangeEvent.target.value);
    });
  });

  describe('render', () => {
    beforeEach(() => {
      instance = new Ui()
      instance.state.storeData = instance.state.storeData.set('track', 'the track')
      instance.state.storeData = instance.state.storeData.set('user_id', '1')
      instance.state.storeData = instance.state.storeData.set('time', 123)
      spyOn(instance, 'sidePanelHTML');
    });
    it('calls sidePanelHTML', () => {
      instance.render();
      expect(instance.sidePanelHTML).toHaveBeenCalledWith('the track', '1', 123);
    });
  });
});
