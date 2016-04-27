import React from 'react';

class Jukebox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      conn: {}
    };
  }

  closeConnection() {
    this.state.conn.close();
  }

  openConnection(self) {
    if (this.state.conn.readyState === undefined || this.state.conn.readyState > 1) {
      console.log("Connecting to the web socket server...")
      var uri = "ws://localhost:8081";
      //var uri = "ws://jukebox.local:8081";
      this.state.conn = new WebSocket(uri);

      this.state.conn.onopen = () => {
        console.log("Socket opened!");
      };

      this.state.conn.onerror = (e) => {
        console.log("Socket error: " + e.message);
      };

      this.state.conn.onclose = (e) => {
        console.log("Socket closed: " + e.code + ' reason:' + e.reason);
      };

      this.state.conn.onmessage = (msg) => {
        var data = JSON.parse(msg.data);
        console.log(data);

        if ("state" in data) {
          self.setState({
            playing: (data["state"] == 'play')
          })
        }

        if ("track" in data) {
          self.setState({
            track: data["track"]
          })
        }

        if ("rating" in data) {
          self.setState({
            rating: data["rating"]
          })
          self.updateRating();
        }

        if ("volume" in data) {
          self.setState({
            volume: data["volume"]
          })
        }

        if ("playlist" in data) {
          self.setState({
            playlist: data["playlist"]
          })
        }

        if ("time" in data) {
          self.setState({
            time: data["time"]
          })
        }

      }
    }
    return this.state.conn;
  }

  buildMPDMessage(self, command, value){
    var payload = {};
    payload[command] = (value || '');
    console.log(payload);
    return payload;
  }

  sendMPDMessage(payload){
    // AsyncStorage.getItem('@User:current_user_id').then((value) => {
    //   payload['user_id'] = parseInt(value);
    //   this.state.conn.send(JSON.stringify(payload));
    // }).done()
  }

  vote(self, state) {
    var payload = this.buildMPDMessage(
      self, 'vote', { 'state': state, 'filename': self.state.track.file }
    );
    this.sendMPDMessage(payload);
  }

  setVolume(self, value) {
    var payload = this.buildMPDMessage(self, 'setvol', value);
    this.sendMPDMessage(payload);
  }

  playNext(self) {
    var payload = this.buildMPDMessage(self, 'next');
    this.sendMPDMessage(payload);
  }

  playPrevious(self) {
    var payload = this.buildMPDMessage(self, 'previous');
    this.sendMPDMessage(payload);
  }

  playPause(self) {
    if(self.state.playing){
      var payload = this.buildMPDMessage(self, 'pause');
    } else {
      var payload = this.buildMPDMessage(self, 'play');
    }
    this.sendMPDMessage(payload);
  }
}

export default Jukebox;
