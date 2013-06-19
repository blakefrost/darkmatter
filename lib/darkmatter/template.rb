module ActionView
  class Template
    alias_method :_old_initialize, :initialize
    def initialize(source, identifier, handler, details)
      _data, source = parse_yaml_front_matter(source)
      @data ||= HashWithIndifferentAccess.new
      @data.merge!(_data)
      _old_initialize(source, identifier, handler, details)
    end

    alias_method :_old_render, :render
    def render(view, locals, buffer=nil, &block)
      unless view.instance_variable_get(:@page)
        view.instance_variable_set(:@page, @data)
      end
      _old_render(view, locals, buffer, &block)
    end

  private

    def parse_yaml_front_matter(content)
      yaml_regex = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      if content =~ yaml_regex
        content = content.sub(yaml_regex, "")

        begin
          data = YAML.load($1)
        rescue *YAML_ERRORS => e
          logger.error "YAML Exception: #{e.message}"
          return false
        end

      else
        return [{}, content]
      end

      [data, content]
    rescue
      [{}, content]
    end

  end
end
