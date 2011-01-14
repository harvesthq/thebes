module Thebes::Sphinxql
  
  class Client < Mysql2::Client

    cattr_accessor :servers

    def initialize *args
      if !args.empty? || (!self.class.servers || self.class.servers.empty?)
        super *args
      else
        super self.class.servers[rand(self.class.servers.size)]
      end
    end

  end

end
