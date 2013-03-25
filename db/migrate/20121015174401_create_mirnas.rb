class CreateMirnas < ActiveRecord::Migration
  def change
    create_table :mirnas do |t|
      t.string :name
    end

    add_index :mirnas, :name, :unique => true
    
  end
end
