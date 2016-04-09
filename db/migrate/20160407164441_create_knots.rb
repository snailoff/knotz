class CreateKnots < ActiveRecord::Migration
  def change
    create_table :knots do |t|
      t.string :name
      t.string :content

      t.timestamps null: false
    end
  end
end
