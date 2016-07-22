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
    Actions.connectionError(Immutable.fromJS(JSON.parse(message)));
  }

  handleClose(message) {
    Actions.connectionClosed(Immutable.fromJS(JSON.parse(message)));
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

  buildMessage(command, value) {
    const payload = {};
    payload[command] = (value || '');
    if (this.userID) {
      payload.user_id = parseInt(this.userID, 10);
    }
    return payload;
  }

  sendMessage(payload) {
    this.conn.send(JSON.stringify(payload));
    this.openConnection(); // TODO figure out why the server sometimes disconnects the client!
  }

  vote(track, state) {
    const payload = this.buildMessage(
      'vote',
      { state: state, filename: track.get('file') }
    );
    this.sendMessage(payload);
  }

  setVolume(value) {
    const payload = this.buildMessage(
      'setvol',
      value
    );
    this.sendMessage(payload);
  }

  next() {
    this.sendMessage(this.buildMessage('next'));
  }

  previous() {
    this.sendMessage(this.buildMessage('previous'));
  }

  play() {
    this.sendMessage(this.buildMessage('play'));
  }

  pause() {
    this.sendMessage(this.buildMessage('pause'));
  }
}

module.exports = Jukebox;
