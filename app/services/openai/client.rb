require "json"
require "net/http"
require "securerandom"
require "tempfile"

module Openai
  class Client
    def self.configured?
      ENV["OPENAI_API_KEY"].present?
    end

    def initialize(api_key: ENV["OPENAI_API_KEY"], base_url: ENV.fetch("OPENAI_BASE_URL", "https://api.openai.com"))
      @api_key = api_key
      @base_uri = URI(base_url)
    end

    def post_json(path, body)
      request = Net::HTTP::Post.new(uri_for(path))
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(body)
      perform(request)
    end

    def get_json(path)
      perform(Net::HTTP::Get.new(uri_for(path)))
    end

    def get_text(path)
      request = Net::HTTP::Get.new(uri_for(path))
      response = perform_raw(request)
      response.body
    end

    def upload_file(filename:, content:, purpose:)
      boundary = "loom-#{SecureRandom.hex(12)}"
      request = Net::HTTP::Post.new(uri_for("/v1/files"))
      request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      request.body = multipart_body(boundary, filename, content, purpose)
      perform(request)
    end

    private

    attr_reader :api_key, :base_uri

    def uri_for(path)
      base_uri + path
    end

    def perform(request)
      JSON.parse(perform_raw(request).body)
    end

    def perform_raw(request)
      raise "OPENAI_API_KEY is not configured" if api_key.blank?

      request["Authorization"] = "Bearer #{api_key}"
      response = Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: request.uri.scheme == "https", read_timeout: 120) do |http|
        http.request(request)
      end

      return response if response.is_a?(Net::HTTPSuccess)

      raise "OpenAI request failed status=#{response.code} body=#{response.body.to_s.truncate(500)}"
    end

    def multipart_body(boundary, filename, content, purpose)
      [
        "--#{boundary}\r\n",
        "Content-Disposition: form-data; name=\"purpose\"\r\n\r\n",
        "#{purpose}\r\n",
        "--#{boundary}\r\n",
        "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n",
        "Content-Type: application/jsonl\r\n\r\n",
        content,
        "\r\n--#{boundary}--\r\n"
      ].join
    end
  end
end
