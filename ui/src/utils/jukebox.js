import Actions from '../actions/actions';

class Jukebox {
  constructor(conn) {
    this.conn = conn || {};
  }

  websocketServerURI() {
    return ('ws://localhost:8081');
    // return ('ws://jukebox.local:8081');
  }

  openConnection() {
    if (!this.connectionReady()) {
      this.conn = new WebSocket(this.websocketServerURI());
      this.conn.onopen = this.handleOpen;
      this.conn.onerror = this.handleError;
      this.conn.onclose = this.handleClose;
      this.conn.onmessage = this.handleMessage;
    }
    return this.conn;
  }

  connectionReady() {
    return !(
      this.conn === undefined ||
      this.conn.readyState === undefined ||
      this.conn.readyState > 1
    );
  }

  handleOpen() {
    Actions.connectionOpen();
  }

  handleError(message) {
    Actions.connectionError(message);
  }

  handleClose(message) {
    Actions.connectionClosed(message);
  }

  handleMessage(message) {
    const data = JSON.parse(message.data);

    // if ("state" in data) {
    //   // self.setState({
    //   //   playing: (data["state"] == 'play')
    //   // })
    // }

    if ('track' in data) {
      Actions.updateTrack(data.track);
    }

    // if ("rating" in data) {
    //   // self.setState({
    //   //   rating: data["rating"]
    //   // })
    //   //self.updateRating();
    // }

    // if ("volume" in data) {
    //   // self.setState({
    //   //   volume: data["volume"]
    //   // })
    // }

    // if ("playlist" in data) {
    //   // self.setState({
    //   //   playlist: data["playlist"]
    //   // })
    // }

    if ('time' in data) {
      Actions.updateTime(data.time);
    }
  }

  buildMessage(command, value, userID) {
    const payload = {};
    payload[command] = (value || '');
    if (userID) {
      payload.user_id = parseInt(userID, 10);
    }
    return payload;
  }

  sendMessage(payload) {
    this.conn.send(JSON.stringify(payload));
    this.openConnection(); // TODO figure out why the server sometimes disconnects the client!
  }

  vote(userID, track, state) {
    const payload = this.buildMessage(
      'vote',
      { state: state, filename: track.file },
      userID
    );
    this.sendMessage(payload);
  }

  // setVolume(self, value) {
  //   var payload = this.buildMessage(self, 'setvol', value);
  //   this.sendMessage(payload);
  // }

  // playNext(self) {
  //   var payload = this.buildMessage(self, 'next');
  //   this.sendMessage(payload);
  // }

  // playPrevious(self) {
  //   var payload = this.buildMessage(self, 'previous');
  //   this.sendMessage(payload);
  // }

  // playPause(self) {
  //   if(self.state.playing){
  //     var payload = this.buildMessage(self, 'pause');
  //   } else {
  //     var payload = this.buildMessage(self, 'play');
  //   }
  //   this.sendMessage(payload);
  // }
}

module.exports = Jukebox;
