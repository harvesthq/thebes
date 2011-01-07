#Due credit: large parts ripped out of thinking_sphinx - http://freelancing-god.github.com/ts/en/.

module Thebes

class SphinxSearch

  attr_reader :results

  def initialize options
    @options = options
    @client = Riddle::Client.new(*server)
    @client.limit = options[:per_page] || 20
    @client.offset = offset
    @client.filters = filters
    @client.field_weights = options[:field_weights] if options[:field_weights]
    @client.index_weights = options[:index_weights] || {}
    @client.sort_by = options[:sort_by] if options[:sort_by]
    @client.match_mode = :extended
  end

  def search query
    logger.info "Querying: '#{query}'"
    @total_pages = nil
    @results = { }
    runtime = Benchmark.realtime {
      @results = @client.query(format_query(query), indexes, '')
    }
    logger.error("Sphinx returned an error: #{@results[:error]}") if !@results[:error].blank?
    logger.warn("Sphinx returned a warning: #{@results[:error]}") if !@results[:warning].blank?
    logger.info "Found #{@results[:total_found]} results out of #{total_pages}"
    logger.debug "Sphinx (#{sprintf("%f", runtime)}s)"
    if @options[:ids_only]
      @results[:matches].map{ |match|
        match[:attributes]["sphinx_internal_id"]
      }
    else
      instances_from_matches
    end
  end

  def total_pages
    return 0 if @results[:total].nil?
    @total_pages ||= (@results[:total] / per_page.to_f).ceil
  end

  private

  def server
    Thebes::Query.servers[rand(Thebes::Query.servers.size)]
  end

  def format_query query
    return query unless @options[:star]
    @query ||= (@options[:star] ? star_query(query) : query).strip
  end

  def star_query(query)
    token = @options[:star].is_a?(Regexp) ? @options[:star] : /\w+/u
    query.gsub(/("#{token}(.*?#{token})?"|(?![!-])#{token})/u) do
      pre, proper, post = $`, $&, $'
      # E.g. "@foo", "/2", "~3", but not as part of a token
      is_operator = pre.match(%r{(\W|^)[@~/]\Z})
      # E.g. "foo bar", with quotes
      is_quote    = proper.starts_with?('"') && proper.ends_with?('"')
      has_star    = pre.ends_with?("*") || post.starts_with?("*")
      if is_operator || is_quote || has_star
        proper
      else
        "*#{proper}*"
      end
    end
  end

  def instances_from_matches
    groups = results[:matches].group_by { |match| match[:attributes]["class_crc"] }
    groups.each do |crc, group|
      group.replace(instances_from_class(class_from_crc(crc), group))
    end
    results[:matches].collect do |match|
      groups.detect { |crc, group|
        crc == match[:attributes]["class_crc"]
      }[1].compact.detect { |obj|
        obj.id == match[:attributes]["sphinx_internal_id"]
      }
    end
  end

  def instances_from_class(klass, matches)
    ids = matches.map { |match| match[:attributes]["sphinx_internal_id"] }
    instances = ids.length > 0 ? klass.where(:id => ids) : []
    ids.map { |obj_id| instances.detect { |obj| obj.id == obj_id } }
  end


  def indexes
    if @options[:index]
      return @options[:index]
    end
    @options[:classes].map { |t| ["_core", "_delta"].map { |sufix| "#{t.name.underscore}#{sufix}" }}.flatten.uniq.join(',')
  end

  def logger
    Rails.logger
  end

  def current_page
    @options[:page].blank? ? 1 : @options[:page].to_i
  end

  def offset
    @options[:offset] || ((current_page - 1) * per_page)
  end

  def per_page
    @options[:per_page] || 100
  end

  def filters
    chain = [Riddle::Client::Filter.new('sphinx_deleted', [0])]
    if @options[:with]
      chain << @options[:with].map { |k, v| Riddle::Client::Filter.new(k, filter_value(v))}
    end
    unless @options[:classes]
      raise "You'll need to explicitly pass in a list of AR classes to search as :classes"
    end
    chain << Riddle::Client::Filter.new('class_crc', @options[:classes].map(&:to_crc32))
    chain.flatten
  end

  def class_from_crc(crc)
    @options[:classes].detect { |klass| klass.to_crc32 == crc }
  end

  def filter_value(value)
    case value
    when Range
      filter_value(value.first).first..filter_value(value.last).first
    when Array
      value.map { |v| filter_value(v) }.flatten
    when Time
      [value.to_i]
    when NilClass
      0
    else
      Array(value)
    end
  end


end

end
