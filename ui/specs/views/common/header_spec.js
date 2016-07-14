import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Actions from './../../../src/actions/actions';
import Header from './../../../src/views/common/header';
import Navigation from './../../../src/views/common/navigation';
import DebugPanel from './../../../src/views/common/debug-panel';
import Immutable from 'immutable'

describe('Header', () => {
  let instance;

  describe('updateUserID', () => {
    it('calls Actions.updateUserID with the target value', () => {
      instance = new Header()
      spyOn(Actions, 'updateUserID')
      let onChangeEvent = { target: {value: '1'} }
      instance.updateUserID(onChangeEvent);
      expect(Actions.updateUserID).toHaveBeenCalledWith(onChangeEvent.target.value);
    });
  });

  describe('navigationHTML', () => {
    it('returns an instance of Navigation', () => {
      instance = new Header();
      expect(instance.navigationHTML()).toEqual(<Navigation />);
    });
  });

  describe('debugPanelHTML', () => {
    it('returns an instance of DebugPanel', () => {
      instance = new Header();
      let connection = Immutable.fromJS(
        {open: true, error_message: {message:'error'}, closed_message: {message:'closed'} }
      );
      let debugPanelHTML = TestUtils.renderIntoDocument(
        instance.debugPanelHTML(connection)
      );
      let debugPanel = TestUtils.findRenderedComponentWithType(debugPanelHTML, DebugPanel);
      expect(debugPanel).toBeDefined();
      expect(debugPanel.props.connection).toEqual(connection);
    });
  });

  describe('render', () => {
    let connection
    beforeEach(() => {
      connection = Immutable.fromJS(
        {open: true, error_message: {message:'error'}, closed_message: {message:'closed'} }
      )
      instance = TestUtils.renderIntoDocument(
        <Header connection={connection} />
      );
      spyOn(instance, 'debugPanelHTML');
      spyOn(instance, 'loginHTML');
      spyOn(instance, 'navigationHTML');
      instance.render()
    });
    it('calls debugPanelHTML', () => {
      expect(instance.debugPanelHTML).toHaveBeenCalledWith(connection)
    });
    it('calls loginHTML', () => {
      expect(instance.loginHTML).toHaveBeenCalled();
    });
    it('calls navigationHTML', () => {
      expect(instance.navigationHTML).toHaveBeenCalled();
    });
  });
});
