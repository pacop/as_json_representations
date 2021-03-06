module AsJsonRepresentations
  module ClassMethods
    def representation(name, options={}, &block)
      @representations ||= {}
      @representations[name] = options.merge(block: block)
    end

    def representations
      @representations
    end

    def render_representation(object, options)
      return {} unless (representation = representations[options.delete :representation])

      data = object.instance_exec(options, &representation[:block])

      while representation[:extend] && (representation = representations[representation[:extend]])
        data = object.instance_exec(
          options,
          &representation[:block]
        ).merge(data)
      end

      data
    end
  end

  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      eval %{
        def as_json(options={})
          if !options[:representation] && defined?(super)
            super(options)
          else
            #{base}.render_representation(self, options)
          end
        end
      }
    end
  end
end
