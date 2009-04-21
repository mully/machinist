module Machinist
  
  module MongoRecord
    
    # This method takes care of converting any associated objects,
    # in the hash returned by Lathe#assigned_attributed, into their
    # object ids.
    #
    # For example, let's say we have blueprints like this:
    #
    #   Post.blueprint { }
    #   Comment.blueprint { post }
    #
    # Lathe#assigned_attributes will return { :post => ... }, but
    # we want to pass { :post_id => 1 } to a controller.
    #
    # This method takes care of cleaning this up.
    def self.assigned_attributes_without_associations(lathe)
      attributes = {}
      lathe.assigned_attributes.each_pair do |attribute, value|
        association = lathe.object.class.reflect_on_association(attribute)
        if association && association.macro == :belongs_to
          attributes[association.primary_key_name.to_sym] = value.id
        else
          attributes[attribute] = value
        end
      end
      attributes
    end
    
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
          unless Machinist::MongoRecord.nerfed?
            lathe.object.save!
          end
          lathe.object(&block)
        end

        def make_unsaved(*args)
          returning(Machinist::MongoRecord.with_save_nerfed { make(*args) }) do |object|
            yield object if block_given?
          end
        end
          
        def plan(*args)
          lathe = Lathe.run(self.new, *args)
          Machinist::MongoRecord.assigned_attributes_without_associations(lathe)
        end
      end
    end  
  end
end

class MongoRecord::Base
  include Machinist::MongoRecord::Extensions
end


