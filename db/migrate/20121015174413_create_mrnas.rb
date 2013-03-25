class CreateMrnas < ActiveRecord::Migration
  def change
    create_table :mrnas do |t|
      t.string :symbol
      t.string :name
    end

    add_index :mrnas, :symbol, :unique => true

  end
end
