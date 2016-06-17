import React from 'react';
import Actions from './../../actions/actions';
import DebugPanel from './debug-panel';
import Navigation from './navigation';

class Header extends React.Component {
  static propTypes = {
    connection: React.PropTypes.object
  };

  debugPanelHTML(connection) {
    return <DebugPanel connection={connection} />;
  }

  navigationHTML() {
    return <Navigation />;
  }

  updateUserID = (onChangeEvent) => {
    Actions.updateUserID(onChangeEvent.target.value);
  }

  loginHTML() {
    return (
      <label>
        User ID: <input type="text" onChange={this.updateUserID} />
      </label>
    );
  }

  render() {
    return (
      <div className="ui-header">
        {this.debugPanelHTML(this.props.connection)}
        {this.loginHTML()}
        {this.navigationHTML()}
      </div>
    );
  }
}

export default Header;
