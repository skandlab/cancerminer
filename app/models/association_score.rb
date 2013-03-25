class AssociationScore < ActiveRecord::Base
  belongs_to :cancer_type
  belongs_to :cross_association_score
  
  attr_accessible :score_regr
end
