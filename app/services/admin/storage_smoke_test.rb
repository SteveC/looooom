require "stringio"

module Admin
  class StorageSmokeTest
    BYTE = "\0".b.freeze
    Result = Struct.new(:service_name, :key, :byte_size, keyword_init: true)

    def self.call
      new.call
    end

    def call
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(BYTE),
        filename: "admin-storage-smoke-test-#{SecureRandom.hex(8)}.bin",
        content_type: "application/octet-stream",
        metadata: { purpose: "admin_storage_smoke_test" },
      )

      raise "downloaded smoke-test bytes did not match upload" unless blob.download == BYTE

      key = blob.key
      service = blob.service
      service_name = blob.service_name
      byte_size = blob.byte_size

      blob.purge

      raise "smoke-test file still exists after delete" if service.exist?(key)

      Result.new(service_name: service_name, key: key, byte_size: byte_size)
    ensure
      blob&.purge if blob&.persisted?
    end
  end
end
