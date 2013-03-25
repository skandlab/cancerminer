class CrossAssociationScore < ActiveRecord::Base
  belongs_to :mirna
  belongs_to :mrna
  has_many :association_scores
  
  attr_accessible :ranks, :relative_ranks, :score, :target_mirsvr, :target_tscan_pct, :target_tscan_contextscore

end
