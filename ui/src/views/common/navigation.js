import React from 'react';
import { Link } from 'react-router';

function Navigation() {
  return (
    <nav className="ui-navigation">
      <ul>
        <li className="ui-navigation__link_container">
          <Link to="/">Playlist</Link>
        </li>
        <li className="ui-navigation__link_container">
          <Link to="/account">Account</Link>
        </li>
      </ul>
    </nav>
  );
}

export default Navigation;
