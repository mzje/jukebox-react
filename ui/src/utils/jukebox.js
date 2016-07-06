import Actions from '../actions/actions';
import Immutable from 'immutable';

class Jukebox {
  constructor(conn) {
    this.conn = conn || {};
  }

  websocketServerURI() {
    // return ('ws://localhost:8081');
    return ('ws://jukebox.local:8081');
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
    const data = Immutable.fromJS(JSON.parse(message.data));
    const track = data.get('track');
    const rating = data.get('rating');
    const time = data.get('time');
    const playlist = data.get('playlist');
    const playState = data.get('state');
    const volume = data.get('volume');

    if (playState) {
      Actions.updatePlayState(playState);
    }

    if (track) {
      Actions.updateTrack(track);
    }

    if (rating) {
      Actions.updateRating(rating);
    }

    if (volume) {
      Actions.updateVolume(volume);
    }

    if (playlist) {
      Actions.updatePlaylist(Immutable.fromJS(playlist));
    }

    if (time) {
      Actions.updateTime(time);
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

  setVolume(userID, value) {
    const payload = this.buildMessage(
      'setvol',
      value,
      userID
    );
    this.sendMessage(payload);
  }

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
