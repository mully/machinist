module Machinist
  module Extensions
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def blueprint(lathe_class = Machinist::Lathe::ActiveRecord, &blueprint)
        @blueprint   = blueprint
        @lathe_class = lathe_class
      end

      def make(attributes = {})
        raise "No blueprint for class #{self}" if @blueprint.nil?
        lathe = @lathe_class.new(self, attributes)
        lathe.instance_eval(&@blueprint)
        lathe.save unless Machinist.nerfed?
        returning(lathe.object) do |object|
          yield object if block_given?
        end
      end
  
      def make_unsaved(attributes = {})
        returning(Machinist.with_save_nerfed { make(attributes) }) do |object|
          yield object if block_given?
        end
      end
    end
  end
end
