require "securerandom"

module Kilden
  # UUID v7 (RFC 9562): 48-bit unix milliseconds, then random bits with the
  # version/variant nibbles pinned. Generated client-side per event so
  # retries stay idempotent — the platform deduplicates on this value.
  # @api private
  module UUID
    CANONICAL = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
    V7 = /\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/

    module_function

    def v7(now_ms = (Process.clock_gettime(Process::CLOCK_REALTIME) * 1000).to_i)
      bytes = [now_ms >> 16, now_ms & 0xFFFF].pack("NS>") + SecureRandom.bytes(10)
      bytes.setbyte(6, (bytes.getbyte(6) & 0x0F) | 0x70)
      bytes.setbyte(8, (bytes.getbyte(8) & 0x3F) | 0x80)
      hex = bytes.unpack1("H*")
      "#{hex[0, 8]}-#{hex[8, 4]}-#{hex[12, 4]}-#{hex[16, 4]}-#{hex[20, 12]}"
    end

    def canonical?(value)
      value.is_a?(String) && CANONICAL.match?(value)
    end
  end
end
