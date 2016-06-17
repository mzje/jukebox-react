import React from 'react';
import { Link } from 'react-router'

class Navigation extends React.Component {
  render() {
    return (
      <nav className='ui-navigation'>
        <ul>
          <li class='ui-navigation__link_container'>
            <Link to='/'>Playlist</Link>
          </li>
          <li class='ui-navigation__link_container'>
            <Link to='/account'>Account</Link>
          </li>
        </ul>
      </nav>
    );
  }
}

export default Navigation;
