import Actions from '../actions/actions';

class Jukebox {
  constructor() {
    this.conn = {};
  }

  websocketServerURI() {
    //return('ws://localhost:8081');
    return('ws://jukebox.local:8081');
  }

  openConnection() {
    if (self.conn === undefined || self.conn.readyState === undefined || self.conn.readyState > 1) {
      console.log("Connecting to the web socket server...")
      self.conn = new WebSocket(this.websocketServerURI());

      self.conn.onopen = () => {
        console.log("Socket opened!");
      };

      self.conn.onerror = (e) => {
        console.log("Socket error: " + e.message);
      };

      self.conn.onclose = (e) => {
        console.log("Socket closed: " + e.code + ' reason:' + e.reason);
      };

      self.conn.onmessage = (msg) => {
        var data = JSON.parse(msg.data);

        if ("state" in data) {
          // self.setState({
          //   playing: (data["state"] == 'play')
          // })
        }

        if ("track" in data) {
          Actions.updateTrack(data['track']);
        }

        if ("rating" in data) {
          // self.setState({
          //   rating: data["rating"]
          // })
          //self.updateRating();
        }

        if ("volume" in data) {
          // self.setState({
          //   volume: data["volume"]
          // })
        }

        if ("playlist" in data) {
          // self.setState({
          //   playlist: data["playlist"]
          // })
        }

        if ("time" in data) {
          // self.setState({
          //   time: data["time"]
          // })
        }

      }
    }
    return self.conn;
  }

  buildMessage(command, value, userID){
    var payload = {};
    payload[command] = (value || '');
    if(userID) {
      payload['user_id'] = parseInt(userID)
    }
    return payload;
  }

  sendMessage(payload){
    self.conn.send(JSON.stringify(payload));
    this.openConnection(); // TODO figure out why the server sometimes disconnects the client!
  }

  vote(userID, track, state) {
    var payload = this.buildMessage(
      'vote',
      { 'state': state, 'filename': track.file },
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
