import React from 'react';
import { render } from 'react-dom';
import { Router, Route, Redirect, browserHistory } from 'react-router';
import UI from './views/ui/ui';
import Playlist from './views/subviews/playlist';
import Account from './views/subviews/account';

render(
  (
    <Router history={ browserHistory } >
      <Route component={ UI } >
        <Route path="/" component={ Playlist } />
        <Route path="/account" component={ Account } />
      </Route>
    </Router>
  ),
  document.getElementById('content')
);
