module Machinist
  module Lathe
    class Base
  
      def initialize(klass, attributes)
        @object = klass.new
        attributes.each {|key, value| @object.send("#{key}=", value) }
        @assigned_attributes = attributes.keys.map(&:to_sym)
      end

      attr_reader :object

      def method_missing(symbol, *args, &block)
        if @assigned_attributes.include?(symbol)
          @object.send(symbol)
        else
          value = if block
            block.call
          elsif args.first.is_a?(Hash) || args.empty?
            symbol.to_s.camelize.constantize.make(args.first || {})
          else
            args.first
          end
          @object.send("#{symbol}=", value)
          @assigned_attributes << symbol
        end
      end
  
    end
  end
end
