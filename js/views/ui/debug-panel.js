import React from 'react';

class DebugPanel extends React.Component {
  openHTML(open) {
    if (open) {
      return <p>Connection Open</p>
    } else {
      return <p>Connection Closed</p>
    }
  }

  errorHTML(error_message) {
    if (error_message) {
      return <p>Error {error_message.message}</p>
    }
  }

  closedHTML(closed_message) {
    if (closed_message) {
      return <p>Closed {closed_message.message}</p>
    }
  }

  render() {
    return (
      <div className='ui-debug-panel'>
        { this.openHTML(this.props.connection.get('open')) }
        { this.errorHTML(this.props.connection.get('error_message')) }
        { this.closedHTML(this.props.connection.get('closed_message')) }
      </div>
    );
  }
}

export default DebugPanel;
