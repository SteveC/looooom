module Admin
  class StorageTestsController < ApplicationController
    before_action :require_configured_admin!

    def create
      result = StorageSmokeTest.call

      redirect_to admin_root_path,
                  notice: "Storage test passed: wrote and deleted a #{result.byte_size}-byte file on #{result.service_name}."
    rescue StandardError => error
      Rails.logger.warn("admin_storage_test_failed error=#{error.class}: #{error.message}")

      redirect_to admin_root_path, alert: "Storage test failed: #{error.class}: #{error.message}"
    end
  end
end
