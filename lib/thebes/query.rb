require 'riddle'
require 'riddle/1.10'

module Thebes

  class Query < Riddle::Client
    cattr_accessor :before_query,
                   :before_running,
                   :servers

    def initiaize *args
      if !args.empty? || self.class.servers.empty?
        super *args
      else
        super *self.class.servers[rand(self.class.servers.size)]
      end
    end

    class << self

      def run &block
        client = new # would take server and port
        before_query.call(client) if before_query
        block.call client
        before_running.call(client) if before_running
        client.run
      end

    end

  end

end
