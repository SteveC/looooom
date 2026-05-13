require "test_helper"

class StorageConfigurationTest < ActiveSupport::TestCase
  test "r2 avoids aws sdk automatic checksum conflicts" do
    configurations = ActiveSupport::ConfigurationFile.parse(Rails.root.join("config/storage.yml"))

    assert_equal "when_required", configurations.dig("r2", "request_checksum_calculation")
    assert_equal "when_required", configurations.dig("r2", "response_checksum_validation")
  end
end
