import React from 'react';

class DebugPanel extends React.Component {
  static propTypes = {
    connection: React.PropTypes.object
  };

  openHTML(open) {
    let html;
    if (open) {
      html = <p>Connection Open</p>;
    } else {
      html = <p>Connection Closed</p>;
    }
    return html;
  }

  errorHTML(errorMessage) {
    let html;
    if (errorMessage) {
      html = <p>Error {errorMessage.message}</p>;
    }
    return html;
  }

  closedHTML(closedMessage) {
    let html;
    if (closedMessage) {
      html = <p>Closed {closedMessage.message}</p>;
    }
    return html;
  }

  render() {
    return (
      <div className="ui-debug-panel">
        {this.openHTML(this.props.connection.get('open'))}
        {this.errorHTML(this.props.connection.get('error_message'))}
        {this.closedHTML(this.props.connection.get('closed_message'))}
      </div>
    );
  }
}

export default DebugPanel;
