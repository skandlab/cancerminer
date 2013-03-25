class Mirna < ActiveRecord::Base
  has_many :cross_association_scores

  attr_accessible :name
end
