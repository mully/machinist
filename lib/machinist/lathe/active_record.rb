require 'machinist/lathe/base'
require 'machinist/extensions'
require 'active_record'

class Machinist::Lathe::ActiveRecord < Machinist::Lathe::Base
  # Undef a couple of methods that are common ActiveRecord attributes.
  # (Both of these are deprecated in Ruby 1.8 anyway.)
  undef_method :id
  undef_method :type
  
  def save
    @object.save!
    @object.reload
  end
end

class ActiveRecord::Base
  include Machinist::Extensions
end
