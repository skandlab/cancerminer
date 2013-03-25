class Mrna < ActiveRecord::Base
  has_many :cross_association_scores
  has_many :mrna_alias
  has_and_belongs_to_many :pathways
  
  attr_accessible :symbol, :name
end
