import React from 'react';

class Account extends React.Component {
  accountHTML() {
    return (
      <p>Account goes here...</p>
    );
  }

  render() {
    return (
      <div className="ui-account">
        {this.accountHTML()}
      </div>
    );
  }
}

export default Account;
