require 'mailman/version'
require 'rest-client'

module Mailman
  BASE_URI = 'mailmanhq.dev:5000'

  class << self
    attr_accessor :subdomain, :api_id, :secret, :recipient

    def configure
      yield self
      is_configured?
    end

    # Posts the message to MailmanHQ
    # Requirements:
    # recipient - Pass this into Mailman.deliver or set it once in Mailman.configure      [REQUIRED]
    # sender    - Name of person sending the message. Used to set the "Sender" header     [REQUIRED]
    # subject   - Subject line of the email                                               [REQUIRED]
    # body      - Body of the email                                                       [REQUIRED]
    # from      - Email of person sending the email. Also used to set the "Sender" header [REQUIRED]
    def deliver(params)
      return false unless is_configured? && valid_params?(params)

      # If :recipient is incoming, we'll use that, otherwise, we'll use
      # what was set in the configure block
      params = { recipient: recipient }.merge!(params)

      if response = client.post(:message => params)
        response.code == 200
      end
    end

    protected
    def client
      @client ||= RestClient::Resource.new("http://#{subdomain}.#{BASE_URI}", :user => api_id, :password => secret)
    end

    def is_configured?
      true & (subdomain && api_id && secret)
    end

    def valid_params?(params)
      valid_keys = [:recipient, :sender, :subject, :body, :from]

      params.each_key { |key| raise ArgumentError, "Unknown key: #{key}" unless valid_keys.include?(key.to_sym) }
    end
  end
end

