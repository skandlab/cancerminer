class CreatePathways < ActiveRecord::Migration
  def change
    create_table :pathways do |t|
      t.string :name
      t.string :url
    end

    add_index :pathways, :name, :unique => true

    # join table
    create_table :mrnas_pathways, :id => false do |t|
      t.integer :mrna_id
      t.integer :pathway_id
    end

    add_index :mrnas_pathways, [:mrna_id, :pathway_id], :unique => true
    add_index :mrnas_pathways, :pathway_id
    
  end
end
