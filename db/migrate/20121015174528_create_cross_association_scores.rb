class CreateCrossAssociationScores < ActiveRecord::Migration
  def change
    create_table :cross_association_scores do |t|
      t.float :score
      t.float :fdr
      t.string :ranks
      t.string :relative_ranks
      t.string :regr_scores
           
      t.float :target_mirsvr
      t.float :target_tscan_pct
      t.float :target_tscan_contextscore

      t.boolean :is_target
      
      t.references :mrna
      t.references :mirna

    end

    add_index :cross_association_scores, :mirna_id, :name => 'cas_mirna'
    add_index :cross_association_scores, :mrna_id, :name => 'cas_mrna'
    add_index :cross_association_scores, :score, :name => 'cas_score'
    
  end
end
