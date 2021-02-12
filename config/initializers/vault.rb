# encoding: UTF-8
# frozen_string_literal: true

require 'vault/totp'
require 'vault/rails'

Vault::Rails.configure do |config|
  config.enabled = Rails.env.production?
  config.address = Peatio::App.config.vault_addr
  config.token = Peatio::App.config.vault_token
  config.ssl_verify = false
  config.timeout = 60
  config.application = Peatio::App.config.vault_app_name
end

if Peatio::App.config.vault_token.to_s != ''
  def renew_process
    token = Vault.auth_token.lookup(Vault.token)
    time = token.data[:ttl] * (1 + rand) * 0.1
    Rails.logger.debug '[VAULT] Token will renew in %.0f sec' % time
    sleep(time)
    Vault.auth_token.renew(token.data[:id])
    Rails.logger.info '[VAULT] Token renewed'
  end

  token = Vault.auth_token.lookup(Vault.token)

  if token.data[:renewable]
    Rails.logger.info '[VAULT] Starting token renew thread'
    Thread.new do
      loop do
        renew_process
      rescue StandardError => e
        report_exception(e)
        sleep 60
      end
    end
  else
    Rails.logger.info '[VAULT] Token is not renewable'
  end
else
  Rails.logger.warn 'Environment variable VAULT_TOKEN is missing'
end
