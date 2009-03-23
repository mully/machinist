module Machinist
  
  module CouchRest
    
    # This sets a flag that stops make from saving objects, so
    # that calls to make from within a blueprint don't create
    # anything inside make_unsaved.
    def self.with_save_nerfed
      begin
        @@nerfed = true
        yield
      ensure
        @@nerfed = false
      end
    end

    @@nerfed = false
    def self.nerfed?
      @@nerfed
    end
    
    module Extensions
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def blueprint(name = :master, &blueprint)
          @blueprints ||= {}
          @blueprints[name] = blueprint if block_given?
          @blueprints[name]
        end
        
        def named_blueprints
          @blueprints.reject{|name,_| name == :master }.keys
        end
        
        def clear_blueprints!
          @blueprints = {}
        end

        def make(*args, &block)
          lathe = Lathe.run(self.new, *args)
          unless Machinist::CouchRest.nerfed?
            lathe.object.save
            # lathe.object.reload
          end
          lathe.object(&block)
        end

        def make_unsaved(*args)
          returning(Machinist::CouchRest.with_save_nerfed { make(*args) }) do |object|
            yield object if block_given?
          end
        end
          
      end
    end
  
    module BelongsToExtensions
      def make(*args, &block)
        lathe = Lathe.run(self.build, *args)
        unless Machinist::CouchRest.nerfed?
          lathe.object.save!
          lathe.object.reload
        end
        lathe.object(&block)
      end

      def plan(*args)
        lathe = Lathe.run(self.build, *args)
        Machinist::CouchRest.assigned_attributes_without_associations(lathe)
      end
    end
  
  end
end

class CouchRest::ExtendedDocument
  include Machinist::CouchRest::Extensions
end
