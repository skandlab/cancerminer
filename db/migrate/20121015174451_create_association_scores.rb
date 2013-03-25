class CreateAssociationScores < ActiveRecord::Migration
  def change
    create_table :association_scores do |t|
      t.float :score_regr
      
      t.references :cancer_type
      t.references :cross_association_score
    end

    add_index :association_scores, :cross_association_score_id, :name => 'as_casid'
    add_index :association_scores, [:cancer_type_id, :score_regr], :name => 'as_ctype_score'
    
  end
end
