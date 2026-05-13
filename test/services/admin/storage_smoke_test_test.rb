require "test_helper"

module Admin
  class StorageSmokeTestTest < ActiveSupport::TestCase
    test "creates verifies and deletes a one byte file" do
      result = StorageSmokeTest.call

      assert_equal "test", result.service_name
      assert_equal 1, result.byte_size
      assert_not ActiveStorage::Blob.service.exist?(result.key)
      assert_not ActiveStorage::Blob.where(key: result.key).exists?
    end
  end
end
