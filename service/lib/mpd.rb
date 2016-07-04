#!/usr/bin/ruby -w
# encoding: utf-8
require 'socket'
require 'song_info'
require 'json'
#
#== Example
#
# require 'mpd'
#
# m = MPD.new('some_host')
# m.play                   => '256'
# m.next                   => '881'
# m.prev                   => '256'
# m.currentsong.title      => 'Ruby Tuesday'
# m.strf('%a - %t')        => 'The Beatles - Ruby Tuesday'
#
#== About
#
#mpd.rb is Copyright (c) 2004, Michael C. Libby (mcl@andsoforth.com)
#
#mpd.rb homepage is: http://www.andsoforth.com/geek/MPD.html
#
#report mpd.rb bugs to mcl@andsoforth.com
#
#Translated and adapted from MPD.pm by Tue Abrahamsen.
#
#== LICENSE
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#See file COPYING for details.
#
class MPD
  MPD_VERSION = '0.13.1' #Version of MPD this version of mpd.rb was tested against
  VERSION = '0.2.1'
  DEFAULT_MPD_HOST = '192.168.1.126'
  DEFAULT_MPD_PORT = 6600

  # Standard MPD error.
  class Error < StandardError; end
  # When something goes wrong with the connection
  class ConnectionError < Error; end

  # When the server returns an error. Superclass. Used for ACK_ERROR_UNKNOWN too.
  class ServerError < Error;  end

  class NotListError < ServerError; end # ACK_ERROR_NOT_LIST <-- unused?
  # ACK_ERROR_ARG - There was an error with one of the arguments.
  class ServerArgumentError < ServerError; end
  # MPD server password incorrect - ACK_ERROR_PASSWORD
  class IncorrectPassword < ServerError; end
  # ACK_ERROR_PERMISSION - not permitted to use the command.
  # (Mostly, the solution is to connect via UNIX domain socket)
  class PermissionError < ServerError; end

  # ACK_ERROR_NO_EXIST - The requested resource was not found
  class NotFound < ServerError; end
  # ACK_ERROR_PLAYLIST_MAX - Playlist is at the max size
  class PlaylistMaxError < ServerError; end
  # ACK_ERROR_SYSTEM - One of the systems has errored.
  class SystemError < ServerError; end
  # ACK_ERROR_PLAYLIST_LOAD - unused?
  class PlaylistLoadError < ServerError; end
  # ACK_ERROR_UPDATE_ALREADY - Already updating the DB.
  class AlreadyUpdating < ServerError; end
  # ACK_ERROR_PLAYER_SYNC - not playing.
  class NotPlaying < ServerError; end
  # ACK_ERROR_EXIST - the resource already exists.
  class AlreadyExists < ServerError; end

  # MPD::SongInfo elements are:
  #
  # +file+ :: full pathname of file as seen by server
  # +album+ :: name of the album
  # +artist+ :: name of the artist
  # +dbid+ :: mpd db id for track
  # +pos+ :: playlist array index (starting at 0)
  # +time+ :: time of track in seconds
  # +title+ :: track title
  # +track+ :: track number within album
  #
  #SongInfo = Struct.new("SongInfo", "file", "album", "artist", "dbid", "pos", "time", "title", "track")

  # MPD::Error elements are:
  #
  # +number+      :: ID number of the error as Integer
  # +index+       :: Line number of the error (0 if not in a command list) as Integer
  # +command+     :: Command name that caused the error
  # +description+ :: Human readable description of the error
  #
  #Error = Struct.new("Error", "number", "index", "command", "description")

  #common regexps precompiled for speed and clarity
  #
  @@re = {
    'ACK_MESSAGE'    => Regexp.new(/^ACK \[(\d+)\@(\d+)\] \{(.*)\} (.+)$/),
    'DIGITS_ONLY'    => Regexp.new(/^\d+$/),
    'OK_MPD_VERSION' => Regexp.new(/^OK MPD (.+)$/),
    'NON_DIGITS'     => Regexp.new(/^\D+$/),
    'LISTALL'        => Regexp.new(/^file:\s/),
    'PING'           => Regexp.new(/^OK/),
    'PLAYLIST'       => Regexp.new(/^(\d+?):(.+)$/),
    'PLAYLISTINFO'   => Regexp.new(/^(.+?):\s(.+)$/),
    'STATS'          => Regexp.new(/^(.+?):\s(.+)$/),
    'STATUS'         => Regexp.new(/^(.+?):\s(.+)$/),
  }

  # If the user has environment variables MPD_HOST or MPD_PORT set, these will override the default
  # settings. Setting host or port in MPD.new will override both the default and the user settings.
  # Defaults are defined in class constants MPD::DEFAULT_MPD_HOST and MPD::DEFAULT_MPD_PORT.
  #

  def initialize(mpd_host = nil, mpd_port = nil)
    #behavior-related
    @overwrite_playlist = true
    @allow_toggle_states = true
    @debug_socket = false

    @mpd_host = mpd_host
    @mpd_host = ENV['MPD_HOST'] if @mpd_host.nil?
    @mpd_host = DEFAULT_MPD_HOST if @mpd_host.nil?

    @mpd_port = mpd_port
    @mpd_port = ENV['MPD_PORT'] if @mpd_port.nil?
    @mpd_port = DEFAULT_MPD_PORT if @mpd_port.nil?

    @socket = nil
    @mpd_version = nil
    @password = nil
    @error = nil
  end

  def self.execute!(command, argument, user_id)
    mpd = instance
    result = argument.blank? ? mpd.send(command) : mpd.send(command, argument)
    mpd.close

    if block_given?
      yield result
    else
      result
    end
  end

  # Saves have to keep having to pass in the creds
  def self.instance
    new Rails.configuration.mpd_host, Rails.configuration.mpd_port
  end

  # Add song at <i>path</i> to the playlist. <i>path</i> is the relative path as seen by the server,
  # not the actual path name of the file on the filesystem.
  #
  def add(path)
    socket_puts("add \"#{path}\"")
  end

  # Adds a 'find track' command to @command_list
  # Used primarily by 'get_tracks_info' method to get track info for multiple tracks in one hit
  #
  def add_find_track_command(filename)
    command("find filename \"#{filename}\"")
  end

  # Mopidy expects a full path for local files
  # I guess this is so it can distinguish between that and a Spotify uri.
  # e.g. "file:///Users/paul/Music/mpd/artist/album/song.mp3"
  def addid(path)
    socket_puts("addid \"#{path}\"")
  end

  # Pass in an JSON object of filenames and it will search for the track and add it to the playlist
  # e.g. {"filenames" : ["foo.mp3, bar.mp3"]}
  #
  def bulk_add_to_playlist(args)
    max_tracks = 10
    tracks = []

    args["filenames"][0...max_tracks].uniq.each do |filename|
      begin
        results = find("filename", filename)
        tracks << results.first.file if results.any?
      rescue => bang
        Rails.logger.error "Error bulk add to playlist: #{bang.message}"
      end
    end if args["filenames"] && args["filenames"].is_a?(Array)

    return tracks if tracks.empty?

    command_list_begin
    tracks.each { |track| command("addid \"#{track}\"") }
    response_ids = command_list_end.collect { |response| response.match(/\d+/)[0] }

    # return SongInfo objects for the songs successfully added to the playlist
    playlistinfo.select { |song| response_ids.include?(song.dbid.to_s) }.sort_by(&:dbid)
  end

  # Clear the playlist of all entries. Consider MPD#save first.
  #
  def clear
    socket_puts("clear")
  end

  # Close the connection to the server.
  #
  def close
    puts "close" if @debug_socket
    @socket.try(:puts, "close")
    @socket = nil
  end

  # Private method for creating command lists.
  #
  def command_list_begin
    @command_list = ["command_list_begin"]
  end

  # Wish this would take a block, but haven't quite figured out to get that to work
  # For now just put commands in the list.
  #
  def command(cmd)
    @command_list << cmd unless @command_list.nil?
  end

  # Closes and executes a command list.
  #
  def command_list_end
    @command_list << "command_list_end"
    sp = @command_list.flatten.join("\n")
    @command_list = []
    socket_puts(sp)
  end

  # Activate a closed connection. Will automatically send password if one has been set.
  #
  def connect
    puts "connecting to socket" if @debug_socket
    @socket = TCPSocket.new(@mpd_host, @mpd_port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    @@re['OK_MPD_VERSION'].match(@socket.try(:gets).try(:chomp))
  rescue Errno::ECONNREFUSED => e
  end

  # Clear every entry from the playlist but the current song.
  #
  # def crop
  #   # this really ought to just generate a list and send that to delete()
  #   command_list_begin
  #   (playlistlength.to_i - 1).downto(currentsong.pos + 1) do |i|
  #     command( "delete #{i}" )
  #   end
  #   (currentsong.pos - 1).downto(0) do |i|
  #     command( "delete #{i}" )
  #   end
  #   command_list_end
  # end

  # Sets the crossfade value (in seconds)
  # #
  # def crossfade(fade_value)
  #   socket_puts("crossfade #{fade_value}")
  #   status['xfade']
  # end

  # Returns an instance of Struct MPD::SongInfo.
  #
  def currentsong
    song = response_to_songinfo(@@re['PLAYLISTINFO'],
                         socket_puts("currentsong")
                         )[0]
    if song # load in who added it
      song.added_command = CommandHistory.includes(:user)
        .where(["command = ? AND command_histories.created_at >= ? AND parameters = ?", "addid", Time.now.ago(1.days), song.filename])
        .order("command_histories.created_at DESC").first
      song.added_by = song.added_command.try(:user).try(:nickname) || "Rainbow Head"
    end
    song
  end

  # Turns off socket command debugging.
  #
  def debug_off
    @debug_socket = false
  end

  # Turns on socket command debugging (prints each socket command to STDERR as well as the socket)
  #
  def debug_on
    @debug_socket = true
  end

  # <i>song</i> is one of:
  # * a song's playlist number,
  # * a song's MPD database ID (if <i>from_id</i> is set to true),
  # * any object that implements a <i>collect</i> function that ultimately boils down to a set of integers. :)
  #
  # Examples:
  # <tt>MPD#delete(1)                  # delete second song (remember playlist starts at index 0)</tt>
  # <tt>MPD#delete(0..4)               # delete first five songs</tt>
  # <tt>MPD#delete(['1', '2', '3'])    # delete songs two, three, and four</tt>
  # <tt>MPD#delete(1..3, 45..48, '99') # delete songs two thru four, forty-six thru forty-nine, and one hundred
  #
  # When <i>from_id</i> is true, the argument(s) will be treated as MPD database IDs.
  # It is not recommended to use ranges with IDs since they are unlikely to be consecutive.
  # An array of IDs, however, would be handy. And don't worry about using indexes in a long list.
  # The function will convert all references to IDs before deleting (as well as removing duplicates).
  def delete(song, from_id = false)
    cmd = from_id ? 'deleteid' : 'delete'
    slist = expand_list(song).flatten.uniq

    if slist.length == 1 then
      return nil unless @@re['DIGITS_ONLY'].match(slist[0].to_s)
      return socket_puts("#{cmd} \"#{slist[0]}\"")
    else
      unless from_id then
        # convert to ID for list commands, otherwise as soon as first delete happens
        # the rest of the indexes won't be accurate
        slist = slist.map{|x| playlistinfo(x).dbid }
      end
      command_list_begin
      slist.each do |x|
        next unless @@re['DIGITS_ONLY'].match(slist[0].to_s)
        command("deleteid \"#{x}\"")
      end
      return command_list_end
    end
  end

  # Returns a Hash of directory name and file information in the given +path+
  def list_directories(path = '')
    dirs = []
    filenames = []
    lsinfo(path).each do |entry|
      if entry.starts_with?("directory: ")
        dir = entry.gsub(/directory: /, "")
        dirs << { :path => dir, :name => dir.split("/").last }
      end
      if entry.starts_with?("file: ")
        filenames << entry.gsub(/file: /, "")
      end
    end
    files = filenames.empty? ? [] : get_tracks_info(filenames)
    return dirs, files
  end

  # Returns a Struct MPD::Error,
  #
  def error
    @error
  end

  # Alias for MPD#delete(song_id, true)
  def deleteid(song_id)
    delete(song_id, true)
  end

  # Takes and prepares any <i>collect</i>able list to be flattened and uniq'ed.
  # That is, it converts <tt>[0..2, '3', [4, 5]]</tt> into <tt>[0, 1, 2, '3', [4, 5]]</tt>.
  # Essentially it expands Range objects and the like.
  #
  def expand_list(d)
    if d.respond_to?("collect") then
      if d.collect == d then
        return d.collect{|x| expand_list(x)}
      else
        dc = d.collect
        if dc.map {|x| x}.size > 1 then
          return d.collect{|x| expand_list(x)}
        else
          return [d]
        end
      end
    else
      return [d]
    end
  end

  # Finds exact matches of <i>find_string</i> in the MPD database.
  # <i>find_type</i> is limited to 'album', 'artist', and 'title'.
  #
  # Returns an array containing an instance of MPD::SongInfo (Struct) for every song in the current
  # playlist.
  #
  # Results from MPD#find() do not have valid information for dbid or pos
  #
  def find(find_type, find_string)
    response_to_songinfo(@@re['PLAYLISTINFO'],
      socket_puts("find #{find_type} \"#{find_string}\"")
    )
  end

  def find_by_artist_and_title(artist, title)
    response_to_songinfo(
      @@re['PLAYLISTINFO'],
      socket_puts("find Artist \"#{artist}\" Title \"#{title}\"")
    )
  end

  def find_by_artist_and_album(artist, album)
    response_to_songinfo(@@re['PLAYLISTINFO'],
      socket_puts("find Artist \"#{artist}\" Album \"#{album}\"")
    )
  end

  # Runs MPD#find using the given parameters and automatically adds each result
  # to the playlist. Returns an Array of MPD::SongInfo structs.
  #
  def find_add(find_type, find_string)
    flist = find(find_type, find_string)
    command_list_begin
    flist.each do |x|
      command("add #{x.file}")
    end
    command_list_end
    flist
  end

  # Get track info for multiple tracks in one hit
  # Pass in an array of tracks you want the mpd info for
  #
  def get_tracks_info(filenames)
    filenames = filenames.is_a?(Array) ? filenames : [filenames]
    command_list_begin
    filenames.each { |filename| add_find_track_command(filename) }
    response_to_songinfo(@@re['PLAYLISTINFO'], command_list_end)
  end

  # Internal method for converting results from currentsong, playlistinfo, playlistid to
  # MPD::SongInfo
  #
  def hash_to_songinfo(h)
    SongInfo.new(
      h['file'],
      h['Album'],
      h['Artist'],
      h['Id'].nil? ? nil : h['Id'].to_i,
      h['Pos'].nil? ? nil : h['Pos'].to_i,
      h['Time'],
      h['Title'],
      h['Track'],
      (@current_song_playing ? @current_song_playing.pos : nil),
      h['KyanTrack'].nil? ? nil : h['KyanTrack']
    )
  end

  # Pings the server and returns true or false depending on whether a response was receieved.
  #
  def is_connected?
    puts "are we connected?" if @debug_socket
    if @socket.nil? || @socket.closed?
      puts "socket: #{@socket.inspect}" if @debug_socket
      puts "socket closed?: #{@socket.try(:closed?)}" if @debug_socket
      return false
    end
    puts "is_connected to socket, about to ping" if @debug_socket
    @socket.puts("ping")
    if @@re['PING'].match(@socket.try(:gets).try(:chomp))
      puts "ping ok" if @debug_socket
      return true
    else
      puts "ping not ok" if @debug_socket
      return false
    end
  rescue => error
    puts "Rescued ping"
    puts "#{error.inspect}"
    false
  end
  private :is_connected?

  # Kill the MPD server.
  # No way exists to restart it from here, so be careful.
  #
  def kill
    socket_puts("kill")
  rescue #kill always causes a readline error in get_server_response
    @error = nil
  end

  # Gets a list of Artist names or Album names from the MPD database (not the current playlist).
  # <i>type</i> is either 'artist' (default) or 'album'. The <i>artist</i> parameter is
  # used with <i>type</i>='album' to limit results to just the albums by that artist.
  #
  def list(type = 'artist', artist = '')
    comm = ["list"]
    comm << type
    comm << "\"#{artist}\"" unless artist.blank?
    response = socket_puts(comm.join(" "))
    tmp = []
    response.each do |f|
      if md = /^(?:Artist|Album):\s(.+)$/.match(f) then
        tmp << md[1]
      end
    end
    return tmp
  end

  # Load a playlist from the MPD playlist directory.
  #
  def load(playlist)
    socket_puts("load \"#{playlist}\"")
    status['playlistid']
  end

  # Returns Array of strings containing a list of directories, files or playlists in <i>path</i> (as
  # seen by the MPD database).
  # If <i>path</i> is omitted, uses the root directory.
  def lsinfo(path = '')
    results = []
    element = {}
    command = "lsinfo"
    command << " \"#{path}\"" if path
    socket_puts(command).each do |f|
      if md = /^(.[^:]+):\s(.+)$/.match(f)
        if ['file', 'playlist', 'directory'].grep(md[1]).length > 0 then
          results.push(f)
        end
      end
    end
    return results
  end

  # Return the version string returned by the MPD server
  #
  def mpd_version
    @mpd_version
  end

  # Play next song in the playlist. See note about shuffling in MPD#set_random
  # Returns songid as Integer.
  #
  def next
    socket_puts("next")
    currentsong
  end

  def outputs
    socket_puts("outputs")
  end

  # Send the password <i>pass</i> to the server and sets it for this MPD instance.
  # If <i>pass</i> is omitted, uses any previously set password (see MPD#password=).
  # Once a password is set by either method MPD#connect can automatically send the password if
  # disconnected.
  #
  def password(pass = @password)
    @password = pass
    socket_puts("password #{pass}")
  end

  # Set the password to <i>pass</i>.
  def password=(pass)
    @password = pass
  end

  # Pause playback on the server
  # Returns ('pause'|'play'|'stop').
  #
  def pause(value = nil)
    cstatus = status['state']
    return cstatus if cstatus == 'stop'

    if value.nil? && @allow_toggle_states then
      value = cstatus == 'pause' ? '0' : '1'
    end
    socket_puts(["pause", "\"#{value}\""].compact.join(" "))
    status['state']
  end

  # Send a ping to the server and keep the connection alive.
  #
  def ping
    socket_puts("ping")
  end

  # Start playback of songs in the playlist with song at index
  # <i>number</i> in the playlist.
  # Empty <i>number</i> starts playing from current spot or beginning.
  # Returns current song as MPD::SongInfo.
  #
  def play(number = '')
    puts "about to send play" if @debug_socket
    command = "play"
    command << " \"#{number}\"" if number.present?
    socket_puts(command)
    puts "send play, now try return currentsong..." if @debug_socket
    currentsong
  end

  # Returns an array containing an instance of MPD::SongInfo (Struct) for every song in the current
  # playlist or a single instance of MPD::SongInfo (if <i>snum</i> is specified).
  # Note that the songid returned is in reference to the playlist and not the database (there are no song ids in the database)
  #
  # <i>snum</i> is the song's index in the playlist.
  # If <i>snum</i> == '-1' then the whole playlist is returned.
  def playlistinfo(snum = -1, from_id = false)
    command = "playlist#{from_id ? 'id' : 'info'}"
    command << " \"#{snum}\"" if snum.present?
    @current_song_playing = currentsong
    plist = response_to_songinfo(@@re['PLAYLISTINFO'],
                                 socket_puts(command)
                                 )
    playlist_tracks = (snum == -1 ? plist : plist[0])
    if snum == -1
      command_histories = CommandHistory.includes(:user).where(["command = ? AND command_histories.created_at >= ? AND parameters IN (?)", "addid", Time.now.ago(2.days), playlist_tracks.map(&:filename)]).order("command_histories.created_at DESC")
      # Estimate the time the track will be played and set the track eta attribute
      playlist_tracks.each do |playlist_track|
        playlist_track.added_by = command_histories.select{ |ch| ch.parameters == playlist_track.file }.first.try(:user).try(:nickname) || "BRH"
        if playlist_track.still_to_be_played?
          total_mins = 0
          total_seconds = 0
          playlist_tracks.each do |track|  # loop through each track on the playlist
            parts = track.duration.split(":") # array of mins, secs
            if (playlist_track.current_song_position <= track.pos && playlist_track.pos > track.pos) # if playing song is before n track and the track we've passed in is after n track
              total_mins = total_mins + parts[0].to_i # add the mins for track n onto total mins
              total_seconds = total_seconds + parts[1].to_i # add the secs for track n onto total secs
            end
          end
          additional = (total_mins + (total_seconds / 60).to_i).to_i # calculate the total additional time
          playlist_track.eta = (Time.now + additional.minutes).strftime("%H:%M") # add that from now and we have the estimate
        end
      end
    end
    playlist_tracks
  end

  def artists_on_playlist
    playlistinfo.map { |track| track.artist }.uniq
  end

  # An alias for MPD#playlistinfo with <i>from_id</i> = true.
  # Looks up song <i>sid</i> is the song's MPD ID (<i>dbid</i> in an MPD::SongInfo
  # instance).
  # Returns an Array of Hashes.
  #
  def playlistid(sid = '')
    playlistinfo(sid, true)
  end

  # Get the length of the playlist from the server.
  # Returns an Integer
  #
  def playlistlength
    status['playlistlength'].to_i
  end

  def playlistsearch(tag, needle)
    plist = response_to_songinfo(@@re['PLAYLISTINFO'],
                                 socket_puts("playlistsearch \"#{tag}\" \"#{needle}\"")
                                 )
    return plist
  end

  # Returns an Array of MPD#SongInfo. The songs listed are either those added since previous
  # playlist version, <i>playlist_num</i>, <b>or</b>, if a song was deleted, the new playlist that
  # resulted. Cumbersome. Eventually methods will be written that help track adds/deletes better.
  #
  # def plchanges(playlist_num = '-1')
  #   response_to_songinfo(@@re['PLAYLISTINFO'],
  #                        socket_puts("plchanges #{playlist_num}")
  #                        )
  # end

  # Play previous song in the playlist. See note about shuffling in MPD#set_random.
  # Return songid as Integer
  #
  def previous
    socket_puts("previous")
    currentsong
  end
  alias prev previous

  # Sets random mode on the server, either directly, or by toggling (if
  # no argument given and @allow_toggle_states = true). Mode "0" = not
  # random; Mode "1" = random. Random affects playback order, but not playlist
  # order. When random is on the playlist is shuffled and then used instead
  # of the actual playlist. Previous and next in random go to the previous
  # and next songs in the shuffled playlist. Calling MPD#next and then
  # MPD#prev would start playback at the beginning of the current song.
  #
  def random(mode = nil)
    return nil if mode.nil? && !@allow_toggle_states
    return nil unless /^(0|1)$/.match(mode) || @allow_toggle_states
    if mode.nil? then
      mode = status['random'] == '1' ? '0' : '1'
    end
    socket_puts("random #{mode}")
    status['random']
  end

  # Sets repeat mode on the server, either directly, or by toggling (if
  # no argument given and @allow_toggle_states = true). Mode "0" = not
  # repeat; Mode "1" = repeat. Repeat means that server will play song 1
  # when it reaches the end of the playlist.
  #
  def repeat(mode = nil)
    return nil if mode.nil? && !@allow_toggle_states
    return nil unless /^(0|1)$/.match(mode) || @allow_toggle_states
    if mode.nil? then
      mode = status['repeat'] == '1' ? '0' : '1'
    end
    socket_puts("repeat #{mode}")
    status['repeat']
  end

  # Private method to convert playlistinfo style server output into MPD#SongInfo list
  # <i>re</i> is the Regexp to use to match "<element type>: <element>".
  # <i>response</i> is the output from MPD#socket_puts.
  # response is an array of strings of mpd track info
  # we can split them out into grouped track attributes by detecting a string that begins "file: "
  # e.g."file: paul/artists/Arcade Fire/Suburbs/10 - Month Of May.mp3"
  def response_to_songinfo(re, response)
    return [] if response.nil?
    list = []
    hash = {}

    # By collecting the filenames first we only need hit the db with one query for the track info
    filenames = []
    response.each do |f|
      if md = re.match(f)
        if md[1] == 'file'
          filenames << md[2]
        end
      end
    end
    filenames = filenames.uniq
    tracks = Track.where(:filename => filenames)

    # Group the attributes into a hash and convert to a SongInfo instance
    response.each do |f|
      if md = re.match(f)
        if md[1] == 'file' # we have a set of mpd track info
          if hash == {} # we have a brand new hash to group this info
            list << nil unless list == []
          else
            list << hash_to_songinfo(hash)
          end
          hash = {} # reset the hash
          hash["KyanTrack"] = tracks.select{ |t| t.filename == md[2] }.first
        end
        hash[md[1]] = md[2] # add the attribute to the hash
      end
    end
    if hash == {}
      list << nil unless list == []
    else
      list << hash_to_songinfo(hash) # add the completed song attributes (converted to the SongInfo class) to the list of results
    end

    # Only return songs!
    # Spotify returns Artist and Album info in the search results
    list.reject! { |result|
      result.title.match(/^(Artist|Album):/)
    }
    return list
  end

  # Deletes the playlist file <i>playlist</i>.m3u from the playlist directory on the server.
  #
  def rm(playlist)
    socket_puts("rm \"#{playlist}\"")
  end

  # Save the current playlist as <i>playlist</i>.m3u in the playlist directory on the server.
  # If <i>force</i> is true, any existing playlist with the same name will be deleted before saving.
  #
  def save(playlist, force = @overwrite_playlist)
    socket_puts("save \"#{playlist}\"")
  rescue
    if error.number == 56 && force then
      rm(playlist)
      return socket_puts("save \"#{playlist}\"")
    end
    raise
  end

  # Similar to MPD#find, only search is not strict. It will match <i>search_type</i> of 'artist',
  # 'album', 'title', or 'filename' against <i>search_string</i>.
  # Returns an Array of MPD#SongInfo.
  #
  def search(search_type, search_string)
    response_to_songinfo(@@re['PLAYLISTINFO'],
                         socket_puts("search #{search_type} \"#{search_string}\"")
                         )
  end

  # Set the volume to <i>volume</i>. Range is limited to 0-100. MPD#set_volume
  # will adjust any value passed less than 0 or greater than 100.
  #
  def setvol(vol)
    vol = 0 if vol.to_i < 0
    vol = 100 if vol.to_i > 100
    socket_puts("setvol \"#{vol}\"")
    status['volume']
  end

  # Sends a command to the MPD server and optionally to STDOUT if
  # MPD#debug_on has been used to turn debugging on
  #
  def socket_puts(cmd)
    puts "just in socket_puts" if @debug_socket
    connect unless is_connected?
    if is_connected?
      puts "socket_puts to socket: #{cmd}" if @debug_socket
      @socket.puts(cmd)
      return get_server_response
    else
      return nil
    end
  end

  # Returns a hash containing various server stats:
  #
  # +albums+ :: number of albums in mpd database
  # +artists+ :: number of artists in mpd database
  # +db_playtime+ :: sum of all song times in in mpd database
  # +db_update+ :: last mpd database update in UNIX time
  # +playtime+ :: time length of music played during uptime
  # +songs+ :: number of songs in mpd database
  # +uptime+ :: mpd server uptime in seconds
  #
  def stats
    s = {}
    socket_puts("stats").each do |f|
      if md = @@re['STATS'].match(f);
        s[md[1]] = md[2]
      end
    end
    return s
  end

  # Returns a hash containing various status elements:
  #
  # +audio+ :: '<sampleRate>:<bits>:<channels>' describes audio stream
  # +bitrate+ :: bitrate of audio stream in kbps
  # +error+ :: if there is an error, returns message here
  # +playlist+ :: the playlist version number as String
  # +playlistlength+ :: number indicating the length of the playlist as String
  # +repeat+ :: '0' or '1'
  # +song+ :: playlist index number of current song (stopped on or playing)
  # +songid+ :: song ID number of current song (stopped on or playing)
  # +state+ :: 'pause'|'play'|'stop'
  # +time+ :: '<elapsed>:<total>' (both in seconds) of current playing/paused song
  # +updating_db+ :: '<job id>' if currently updating db
  # +volume+ :: '0' to '100'
  # +xfade+ :: crossfade in seconds
  #
  def status
    s = {}
    response = socket_puts("status")
    if response
      response.each do |f|
        if md = @@re['STATUS'].match(f) then
          s[md[1]] = md[2]
        end
      end
    end
    return s
  end

  # Stops playback.
  # Returns ('pause'|'play'|'stop').
  #
  def stop
    socket_puts("stop")
    status['state']
  end

  # Pass a format string (like strftime) and get back a string of MPD information.
  #
  # Format string elements are:
  # <tt>%f</tt> :: filename
  # <tt>%a</tt> :: artist
  # <tt>%A</tt> :: album
  # <tt>%i</tt> :: MPD database ID
  # <tt>%p</tt> :: playlist position
  # <tt>%t</tt> :: title
  # <tt>%T</tt> :: track time (in seconds)
  # <tt>%n</tt> :: track number
  # <tt>%e</tt> :: elapsed playtime (MM:SS form)
  # <tt>%l</tt> :: track length (MM:SS form)
  #
  # <i>song_info</i> can either be an existing MPD::SongInfo object (such as the one returned by
  # MPD#currentsong) or the MPD database ID for a song. If no <i>song_info</i> is given, all
  # song-related elements will come from the current song.
  #
  def strf(format_string, song_info = currentsong)
    unless song_info.class == Struct::SongInfo
      if @@re['DIGITS_ONLY'].match(song_info.to_s) then
        song_info = playlistid(song_info)
      end
    end

    s = ''
    format_string.scan(/%[EO]?.|./o) do |x|
      case x
      when '%f'
        s << song_info.file.to_s

      when '%a'
        s << song_info.artist.to_s

      when '%A'
        s << song_info.album.to_s

      when '%i'
        s << song_info.dbid.to_s

      when '%p'
        s << song_info.pos.to_s

      when '%t'
        s << song_info.title.to_s

      when '%T'
        s << song_info.time.to_s

      when '%n'
        s << song_info.track.to_s

      when '%e'
        t = status && status["time"] ? status["time"].split(/:/)[0].to_f : 0
        s << sprintf( "%d:%02d", t / 60, t % 60 )

      when '%l'
        t = status && status["time"] ? status['time'].split(/:/)[1].to_f : 0
        s << sprintf( "%d:%02d", t / 60, t % 60 )

      else
        s << x.to_s

      end
    end
    return s
  end

  # Swap two songs in the playlist, either based on playlist indexes or song IDs (when <i>from_id</i> is true).
  #
  # def swap(song_from, song_to, from_id = false)
  #   if @@re['DIGITS_ONLY'].match(song_from.to_s) && @@re['DIGITS_ONLY'].match(song_to.to_s) then
  #     return socket_puts("#{from_id ? 'swapid' : 'swap'} #{song_from} #{song_to}")
  #   else
  #     raise "invalid input for swap"
  #   end
  # end

  # Alias for MPD#swap(song_id_from, song_id_to, true)
  #
  # def swap_id(song_id_from, song_id_to)
  #   swap(song_id_from, song_id_to, true)
  # end

  # Searches MP3 directory for new music and removes old music from the MPD database.
  # <i>path</i> is an optional argument that specifies a particular directory or
  # song/file to update. <i>path</i> can also be a list of paths to update.
  # If <i>path</i> is omitted, the entire database will be updated using the server's
  # base MP3 directory.
  #
  def update(path = '')
    path = path.match(/\s|'/) ? %Q["#{path}"] : path
    ulist = expand_list(path).flatten.uniq
    if ulist.length == 1 then
      update_command = "update"
      update_command << " \"#{ulist[0]}\"" if ulist[0].present?
      return socket_puts(update_command)
    else
      command_list_begin
      ulist.each do |x|
        update_command = "update"
        update_command << " \"#{x}\"" if x.present?
        command(update_command)
      end
      return command_list_end
    end
  end

  # Returns the types of URLs that can be handled by the server.
  #
  def urlhandlers
    handlers = []
    socket_puts("urlhandlers").each do |f|
      handlers << f if /^handler: (.+)$/.match(f)
    end
    return handlers
  end

  def get_server_response
    timeout = 5
    ready = IO.select([@socket], nil, nil, timeout)
    msg = []

    unless ready
      # this is a start of an attempt to fix the issue of
      # mpd hanging.
      Rails.logger.error "The MPD socket failed. Exiting."
      return []
    end

    while true
      case line = @socket.gets
      when "OK\n", nil
        break
      when /^ACK/
        error = line
        break
      else
        msg << line
      end
    end

    return msg unless error
    err = error.match(/^ACK \[(?<code>\d+)\@(?<pos>\d+)\] \{(?<command>.*)\} (?<message>.+)$/)
    raise SERVER_ERRORS[err[:code].to_i], "[#{err[:command]}] #{err[:message]}"
  end

  SERVER_ERRORS = {
    1 => NotListError,
    2 => ServerArgumentError,
    3 => IncorrectPassword,
    4 => PermissionError,
    5 => ServerError,

    50 => NotFound,
    51 => PlaylistMaxError,
    52 => SystemError,
    53 => PlaylistLoadError,
    54 => AlreadyUpdating,
    55 => NotPlaying,
    56 => AlreadyExists
  }

  private :command, :command_list_begin, :command_list_end, :expand_list
  private :connect, :get_server_response, :socket_puts
  private :hash_to_songinfo, :response_to_songinfo
end
