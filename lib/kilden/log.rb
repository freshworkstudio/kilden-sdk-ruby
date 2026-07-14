# frozen_string_literal: true

module Kilden
  # Minimal leveled logger writing to $stderr. The stdlib logger is leaving
  # the default gems (Ruby 4), and this SDK ships zero dependencies — so the
  # default is this. Anything responding to debug/info/warn/error can
  # replace it through the client's logger: option.
  # @api private
  class Log
    LEVELS = { debug: 0, info: 1, warn: 2, error: 3 }.freeze

    def initialize(level)
      @threshold = LEVELS.fetch(level)
    end

    LEVELS.each do |name, severity|
      define_method(name) do |message|
        warn("kilden [#{name}] #{message}") if severity >= @threshold
        nil
      end
    end
  end
end
