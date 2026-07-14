# frozen_string_literal: true

require "openssl"

module Kilden
  # Signs the short-lived identity tokens that make browser events
  # verifiable (Kilden's trust model). Deliberately separate from Client: a
  # controller rendering a page wants a token, not an event queue.
  #
  #   signer = Kilden::IdentitySigner.new(ENV["KILDEN_IDENTITY_SECRET"], kid: "k1")
  #   token  = signer.sign(current_user.id.to_s, traits: { plan: "pro" })
  #
  # Only sign a +sub+ your backend authenticated. Signing user input
  # (params[:user_id]) lets anyone impersonate anyone — with a "verified"
  # stamp on top.
  #
  # HS256 is implemented by hand because the spec freezes the byte form of
  # the token (kilden-sdk-spec §6.1); a JWT library's serialization choices
  # would silently diverge.
  class IdentitySigner
    MAX_TTL = 604_800 # 7 days; identity tokens are short-lived by design

    def initialize(identity_secret, kid:)
      if !identity_secret.is_a?(String) || identity_secret.empty?
        raise ConfigurationError,
              "identity secret is required"
      end
      if !kid.is_a?(String) || kid.empty?
        raise ConfigurationError,
              "kid is required (the platform looks the secret up by kid)"
      end

      @secret = identity_secret
      @kid = kid
    end

    # Returns the signed JWT for +sub+ (the distinct_id the token vouches
    # for). ttl defaults to one hour and is capped at 7 days.
    def sign(sub, ttl: 3600, traits: nil)
      raise ArgumentError, "sub must be a non-empty string" if !sub.is_a?(String) || sub.empty?
      raise ArgumentError, "ttl must be in (0, #{MAX_TTL}] seconds" if !ttl.is_a?(Integer) || ttl <= 0 || ttl > MAX_TTL

      iat = Time.now.to_i
      build(sub, iat: iat, exp: iat + ttl, traits: traits)
    end

    private

    def build(sub, iat:, exp:, traits:)
      header = CanonicalJSON.generate({ "alg" => "HS256", "kid" => @kid, "typ" => "JWT" })
      claims = { "exp" => exp, "iat" => iat, "sub" => sub }
      claims["traits"] = traits if traits && !traits.empty?
      payload = CanonicalJSON.generate(claims)

      signing_input = "#{b64url(header)}.#{b64url(payload)}"
      signature = OpenSSL::HMAC.digest("SHA256", @secret, signing_input)
      "#{signing_input}.#{b64url(signature)}"
    end

    # base64url without padding, via Array#pack — the base64 stdlib moved
    # out of the default gems in Ruby 3.4 and this SDK ships zero deps.
    def b64url(bytes)
      [bytes].pack("m0").tr("+/", "-_").delete("=")
    end
  end
end
