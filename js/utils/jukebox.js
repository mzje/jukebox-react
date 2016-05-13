import Actions from '../actions/actions';

class Jukebox {
  constructor() {
    this.conn = {};
  }

  openConnection() {
    if (self.conn === undefined || self.conn.readyState === undefined || self.conn.readyState > 1) {
      console.log("Connecting to the web socket server...")
      //var uri = "ws://localhost:8081";
      var uri = "ws://jukebox.local:8081";
      self.conn = new WebSocket(uri);

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

  buildMPDMessage(command, value){
    var payload = {};
    payload[command] = (value || '');
    console.log(payload);
    return payload;
  }

  sendMPDMessage(payload){
    console.log('sendMPDMessage');
    // AsyncStorage.getItem('@User:current_user_id').then((value) => {
    //   payload['user_id'] = parseInt(value);
    //   this.state.conn.send(JSON.stringify(payload));
    // }).done()
  }

  vote(track, state) {
    var payload = this.buildMPDMessage(
      'vote', { 'state': state, 'filename': track.file }
    );
    this.sendMPDMessage(payload);
  }

  // setVolume(self, value) {
  //   var payload = this.buildMPDMessage(self, 'setvol', value);
  //   this.sendMPDMessage(payload);
  // }

  // playNext(self) {
  //   var payload = this.buildMPDMessage(self, 'next');
  //   this.sendMPDMessage(payload);
  // }

  // playPrevious(self) {
  //   var payload = this.buildMPDMessage(self, 'previous');
  //   this.sendMPDMessage(payload);
  // }

  // playPause(self) {
  //   if(self.state.playing){
  //     var payload = this.buildMPDMessage(self, 'pause');
  //   } else {
  //     var payload = this.buildMPDMessage(self, 'play');
  //   }
  //   this.sendMPDMessage(payload);
  // }
}

export default Jukebox;
