class CreateMrnaAliases < ActiveRecord::Migration
  def change
    create_table :mrna_aliases do |t|
      t.string :alias
      t.references :mrna
    end

    add_index :mrna_aliases, :alias

  end
end
