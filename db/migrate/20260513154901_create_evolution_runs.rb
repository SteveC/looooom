class CreateEvolutionRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :evolution_runs do |t|
      t.references :ticket, null: true, foreign_key: true
      t.string :status, null: false, default: "reported"
      t.string :branch_name
      t.string :pull_request_url
      t.text :summary
      t.text :validation
      t.jsonb :runner_metadata, null: false, default: {}
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :evolution_runs, :status
    add_index :evolution_runs, :pull_request_url
  end
end
