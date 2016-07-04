require 'json'

class MessageDispatcher
  attr_reader :payload, :user_id

  MPD_CALLS  = [
    :play, :pause, :next, :previous, :bulk_add_to_playlist,
    :setvol, :deleteid, :addid, :clear
  ]
  JB_CALLS = [:vote]

  # "{\"user_id\": null,\"setvol\": 40}"
  #
  def initialize(payload)
    @payload = payload
    @user_id = nil

    extract!
  end

  def self.send!(payload)
    new(payload).send(:send!)
  end

  private

  def send!
    payload_from_json.each do |cmd, args|
      send("#{command_type?(cmd)}_call!", cmd.downcase, args)
    end
  end

  def extract!
    @user_id = payload_from_json.delete('user_id')
  end

  def payload_from_json
    @payload_from_json ||= JSON.parse(payload).with_indifferent_access
  end

  def command_type?(cmd)
    cmd = cmd.downcase.to_sym
    [:mpd, :jb].each do |cmd_type|
      return cmd_type if self.class.const_get("#{cmd_type.upcase}_CALLS").include?(cmd)
    end

    :unknown
  end

  def mpd_call!(cmd, arguments)
    MPD.execute!(cmd, arguments, @user_id) do |result|
      CommandHistory.record!(cmd, arguments, @user_id, result) unless result.nil?
    end
  end

  def jb_call!(cmd, arguments)
    JbCall::Handler.execute!(cmd, arguments, @user_id) do |result|
      CommandHistory.record!(cmd, arguments, @user_id, result) unless result.nil?
    end
  end

  def unknown_call!(cmd, arguments)
    # TO DO
  end
end
