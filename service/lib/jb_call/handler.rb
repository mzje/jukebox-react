module JbCall
  class Handler
    include JbCall::Vote

    def self.execute!(*args)
      result = new(*args).send(:make_call!)

      if block_given?
        yield result
      else
        result
      end
    end

    def initialize(command, arguments, user_id)
      @user_id = user_id
      @command = command
      @arguments = parse_args arguments
    end

    private

    def make_call!
      send(@command)
    end

    def parse_args(args)
      args = { value:args } unless args.is_a?(Hash)
      OpenStruct.new(args)
    end
  end
end