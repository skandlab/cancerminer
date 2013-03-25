class TargetInteraction < ActiveRecord::Base
  belongs_to :mrna
  belongs_to :mirna
  
  attr_accessible :mirsvr, :tscan_contextscore, :tscan_pct
end
