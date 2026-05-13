class PollOpenaiBatchJob < ApplicationJob
  queue_as :default

  def perform(openai_batch_job_id)
    batch_job = OpenaiBatchJob.find(openai_batch_job_id)
    return unless batch_job.openai_batch_id.present?
    return unless batch_job.active?

    client = Openai::Client.new
    batch = client.get_json("/v1/batches/#{batch_job.openai_batch_id}")
    batch_job.update!(
      status: batch.fetch("status"),
      output_file_id: batch["output_file_id"],
      error_file_id: batch["error_file_id"],
      completed_at: completed?(batch) ? Time.current : nil,
      metadata: batch_job.metadata.merge(last_polled_at: Time.current.iso8601)
    )

    if batch_job.status == "completed" && batch_job.output_file_id.present?
      content = client.get_text("/v1/files/#{batch_job.output_file_id}/content")
      Openai::TicketBatchResultApplier.new(batch_job, content).call
    elsif batch_job.active?
      PollOpenaiBatchJob.set(wait: 10.minutes).perform_later(batch_job.id)
    end
  end

  private

  def completed?(batch)
    batch.fetch("status").in?(%w[completed failed expired cancelled])
  end
end
