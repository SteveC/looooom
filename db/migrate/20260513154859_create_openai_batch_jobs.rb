class CreateOpenaiBatchJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :openai_batch_jobs do |t|
      t.string :purpose, null: false
      t.string :openai_batch_id
      t.string :status, null: false, default: "queued"
      t.string :input_file_id
      t.string :output_file_id
      t.string :error_file_id
      t.datetime :requested_at
      t.datetime :completed_at
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :openai_batch_jobs, :openai_batch_id, unique: true
    add_index :openai_batch_jobs, [ :purpose, :status ]
  end
end
