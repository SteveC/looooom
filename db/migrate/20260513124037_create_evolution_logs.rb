class CreateEvolutionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :evolution_logs do |t|
      t.string :trigger, null: false
      t.string :status, null: false, default: "queued"
      t.text :summary
      t.text :prompt
      t.text :output
      t.string :branch
      t.string :pull_request_url
      t.jsonb :metrics_before, null: false, default: {}
      t.jsonb :metrics_after, null: false, default: {}
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :evolution_logs, :status
    add_index :evolution_logs, :created_at
  end
end
