import React from 'react';
import TestUtils from 'react/lib/ReactTestUtils';
import Navigation from './../../../js/views/ui/navigation';
import { Link } from 'react-router'

describe('Navigation', () => {
  let instance;

  describe('render', () => {
    beforeEach(() => {
      instance = TestUtils.renderIntoDocument(<Navigation />);
    });
    it('returns 2 links', () => {
      let links = TestUtils.scryRenderedDOMComponentsWithTag(instance, 'a')
      expect(links.length).toEqual(2);
    });

    it('returns a link to the root', () => {
      let links = TestUtils.scryRenderedComponentsWithType(instance, Link)
      expect(links[0].props.to).toEqual('/')
    });

    it('returns a link to the account', () => {
      let links = TestUtils.scryRenderedComponentsWithType(instance, Link)
      expect(links[1].props.to).toEqual('/account')
    });
  });
});
