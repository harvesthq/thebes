require 'action_view'

module Thebes

  class ConfigWriter

    def initialize template_path=nil, template_file=nil
      @template_path = template_path || File.join(File.dirname(__FILE__), '..', '..', 'templates')
      @template_file = template_file || 'sphinx.conf'
    end
    
    def default_config_file
      "./#{@@config_template}"
    end

    def build(outfile=nil, locals={})
      outfile ||= default_config_file
      view = ActionView::Base.new(
        @template_path,
        locals
      )
      File.open(outfile, 'w') do |file|
        file.write view.render(:file => @template_file)
      end
    end

  end

end
