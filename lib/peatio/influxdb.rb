# encoding: UTF-8
# frozen_string_literal: true

module Peatio
  module InfluxDB
    class << self
      @@retention_policies = {
        :trades => :one_month,
        :candles_1m => :two_weeks,
        :candles_5m => :two_weeks,
        :candles_15m => :six_months,
        :candles_30m => :six_months,
        :candles_1h => :six_months,
        :candles_2h => :forever,
        :candles_4h => :forever,
        :candles_6h => :forever,
        :candles_12h => :forever,
        :candles_1d => :forever,
        :candles_3d => :forever,
        :candles_1w => :forever,
      }

      @@rp_durations = {
        :two_weeks => 2.weeks,
        :one_month => 4.weeks,
        :six_months => 24.weeks
      }

      def client(opts={})
        # Map InfluxDB clients with received opts.
        clients[opts] ||= ::InfluxDB::Client.new(parse(config.merge(opts)))
      end

      def config
        yaml = ::Pathname.new("config/influxdb.yml")
        return {} unless yaml.exist?

        erb = ::ERB.new(yaml.read)
        ::SafeYAML.load(erb.result)[ENV.fetch('RAILS_ENV', 'development')].symbolize_keys || {}
      end

      def clients
        @clients ||= {}
      end

      def parse(configs)
        hosts = configs[:host]
        configs[:host] = hosts[Zlib::crc32(configs[:keyshard].to_s) % hosts.count]
        configs
      end

      def rp_enabled
        @@rp_enabled ||= config[:rp_enabled]
      end

      def m_to_rp(measurement)
        return rp_enabled ? @@retention_policies[measurement.to_sym] : nil
      end

      def check_write_to_rp(measurement, time)
        dur = @@rp_durations[@@retention_policies[measurement.to_sym]]
        return !dur || time > Time.now - dur
      end

      def m_with_rp(measurement)
        return rp_enabled ? "#{m_to_rp(measurement)}.#{measurement}" : measurement
      end
    end
  end
end
