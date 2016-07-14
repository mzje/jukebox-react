import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import DebugPanel from './../../../src/views/common/debug-panel';
import Immutable from 'immutable'

describe('DebugPanel', () => {
  let instance;

  describe('openHTML', () => {
    beforeEach(() => {
      instance = new DebugPanel();
    });
    describe('when open is true', () => {
      it('returns Connection Open', () => {
        let openHtml = TestUtils.renderIntoDocument(
          instance.openHTML(true)
        )
        expect(openHtml.innerText).toEqual('Connection Open');
      })
    });
    describe('when open is false', () => {
      it('returns Connection Closed', () => {
        let openHtml = TestUtils.renderIntoDocument(
          instance.openHTML(false)
        )
        expect(openHtml.innerText).toEqual('Connection Closed');
      })
    });
  });

  describe('errorHTML', () => {
    beforeEach(() => {
      instance = new DebugPanel();
    });
    describe('when there is an error', () => {
      it('returns the error message', () => {
        let message = Immutable.fromJS({ message: 'Is Foo' });
        let errorHTML = TestUtils.renderIntoDocument(
          instance.errorHTML(message)
        )
        expect(errorHTML.innerText).toEqual('Error Is Foo');
      });
    });
    describe('when there is not an error', () => {
      it('returns nothing', () => {
        expect(instance.errorHTML()).toBeUndefined();
      });
    });
  });

  describe('closedHTML', () => {
    beforeEach(() => {
      instance = new DebugPanel();
    });
    describe('when there is not a message', () => {
      it('returns the closed message', () => {
        let message = Immutable.fromJS({ message: 'it is' });
        let closedHTML = TestUtils.renderIntoDocument(
          instance.closedHTML(message)
        )
        expect(closedHTML.innerText).toEqual('Closed it is');
      });
    });
    describe('when there is a message', () => {
      it('returns nothing', () => {
        expect(instance.closedHTML()).toBeUndefined();
      });
    });
  });

  describe('render', () => {
    beforeEach(() => {
      instance = new DebugPanel({
        connection: Immutable.fromJS(
          {open: true, error_message: 'error', closed_message: 'closed' }
        )
      })
      spyOn(instance, 'openHTML');
      spyOn(instance, 'errorHTML');
      spyOn(instance, 'closedHTML');
    });
    it('calls openHTML', () => {
      instance.render();
      expect(instance.openHTML).toHaveBeenCalledWith(true);
    });
    it('calls errorHTML', () => {
      instance.render();
      expect(instance.errorHTML).toHaveBeenCalledWith('error');
    });
    it('calls closedHTML', () => {
      instance.render();
      expect(instance.closedHTML).toHaveBeenCalledWith('closed');
    });
  });
});
