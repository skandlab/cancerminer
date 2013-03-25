class CancerType < ActiveRecord::Base
  has_many :association_scores
  
  attr_accessible :color, :description, :name, :sample_count
end
