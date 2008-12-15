require 'machinist/extensions'
require 'machinist/lathe/base'
require 'machinist/lathe/active_record'
require 'sham'
 
module Machinist
  @@nerfed = false
  def self.nerfed?
    @@nerfed
  end
  
  def self.with_save_nerfed
    begin
      @@nerfed = true
      yield
    ensure
      @@nerfed = false
    end
  end
end
