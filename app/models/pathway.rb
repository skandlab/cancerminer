class Pathway < ActiveRecord::Base
  has_and_belongs_to_many :mrnas

  attr_accessible :name, :url
end
