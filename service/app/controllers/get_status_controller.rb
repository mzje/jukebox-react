# A class for getting the current status of the jukebox in json
# Note we inherit from ActionController::Metal for speed benefits!
# When updating this class you will need to restart the server
class GetStatusController < ActionController::Metal

  def get_status
    self.content_type = "application/json"
    self.response_body = CurrentStatus.to_json
    self.status = 200
  end

end