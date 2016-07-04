require 'active_support/concern'

module JbCall
  module Vote
    extend ActiveSupport::Concern

    private

    def vote
      if @arguments.filename.present? && @arguments.state.present?
        VoteHandler.vote!(@arguments.filename, @arguments.state, @user_id)
      end
    end
  end
end