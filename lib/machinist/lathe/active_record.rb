require 'machinist/lathe/base'
require 'machinist/extensions'
require 'active_record'

class Machinist::Lathe::ActiveRecord < Machinist::Lathe::Base
  def save
    @object.save!
    @object.reload
  end
end

class ActiveRecord::Base
  include Machinist::Extensions
end
