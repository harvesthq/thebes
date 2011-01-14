module Thebes::Sphinxql
  
  class Query

    def initialize query
      @query = query
      @client = Client.new
    end

    def run
      @client.query self.to_sql
    end

    def to_sql
      case @query
      when String
        @query
      when Array
        @query.shift % (@query.collect { |q|
          @client.escape(q)
        })
      end
    end

    class << self

      def run query
        self.new(query).run
      end

    end

  end

end
