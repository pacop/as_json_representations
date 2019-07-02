module AsJsonRepresentations
  module Collection
    def representation(name, options={})
      as_json(options.merge(representation: name))
    end

    def self.included(base)
      base.class_eval do
        def as_json(options={})
          # call supported methods of ActiveRecord::QueryMethods
          [:includes].each do |method|
            next unless respond_to? method

            args = klass.representations.dig(options[:representation], method)
            public_send(method, args) if args
          end

          return super if respond_to? :super

          map do |item|
            item.respond_to?(:as_json) ? item.as_json(options) : item
          end
        end
      end
    end
  end
end
