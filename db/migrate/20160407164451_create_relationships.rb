class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string :knot_id
      t.string :piece_id

      t.timestamps null: false
    end
  end
end
