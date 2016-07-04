class Connection
  attr_accessor :socket, :user_id

  def initialize(socket, user_id)
    @socket = socket
    @user_id = user_id
  end
end