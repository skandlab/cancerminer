class CreateCancerTypes < ActiveRecord::Migration
  def change
    create_table :cancer_types do |t|
      t.string :name
      t.string :description
      t.integer :sample_count
      t.string :color

    end

    add_index :cancer_types, :name, :unique => true

  end
end
