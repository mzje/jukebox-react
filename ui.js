class NowPlaying extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      conn: {}
    };
  }

  componentDidMount() {
    let uri = "ws://jukebox.local:8081";
    this.state.conn = new WebSocket(uri);
    this.state.conn.onopen = () => {
      console.log("Socket opened!");
    };
    this.state.conn.onmessage = (msg) => {
      var data = JSON.parse(msg.data);
      if (data['track']) {
        this.setState({
          track: data['track']
        })
      }
    }
  }
  render() {
    let trackTitle;
    if (this.state.track) {
      console.log(this.state.track)
      trackTitle = this.state.track['title'];
    } else {
      trackTitle = 'Loading...'
    }
    return (
      <div>
        <p>{ trackTitle }</p>
      </div>
    );
  }
}

class UI extends React.Component {
  render() {
    return (
      <div>
        <NowPlaying />
      </div>
    );
  }
}


ReactDOM.render(
  <UI />,
  document.getElementById('container')
);
