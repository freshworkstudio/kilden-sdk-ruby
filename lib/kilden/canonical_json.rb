require "json"

module Kilden
  # The canonical JSON form frozen by the spec (§6.1) so identity tokens are
  # byte-identical across the five SDKs: object keys sorted lexicographically
  # (byte order) at every nesting level, compact separators, UTF-8 preserved,
  # and the three HTML-unsafe ASCII characters escaped the way Go's
  # encoding/json does — the platform's reference generator.
  # @api private
  module CanonicalJSON
    HTML_UNSAFE = { "&" => "\\u0026", "<" => "\\u003c", ">" => "\\u003e" }.freeze

    module_function

    def generate(value)
      case value
      when Hash
        pairs = value.keys.map(&:to_s).sort.map do |key|
          raw = value.key?(key) ? value[key] : value[key.to_sym]
          "#{string(key)}:#{generate(raw)}"
        end
        "{#{pairs.join(",")}}"
      when Array
        "[#{value.map { |v| generate(v) }.join(",")}]"
      when String
        string(value)
      when Integer, Float, TrueClass, FalseClass
        JSON.generate(value)
      when nil
        "null"
      else
        string(value.to_s)
      end
    end

    def string(value)
      JSON.generate(value).gsub(/[&<>]/, HTML_UNSAFE)
    end
  end
end
