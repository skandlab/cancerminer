class MrnaAlias < ActiveRecord::Base
  belongs_to :mrna
  
  attr_accessible :alias
end
