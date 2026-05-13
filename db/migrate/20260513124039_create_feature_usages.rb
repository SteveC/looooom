class CreateFeatureUsages < ActiveRecord::Migration[8.1]
  def change
    create_table :feature_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_name, null: false
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :feature_usages, :event_name
    add_index :feature_usages, :occurred_at
  end
end
