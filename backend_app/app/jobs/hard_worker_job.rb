# app/jobs/hard_worker_job.rb
class HardWorkerJob < ApplicationJob
  queue_as :default

  def perform(name)
    puts "👋 Hello, #{name} from Sidekiq"
  end
end
