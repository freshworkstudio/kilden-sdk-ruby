# Kilden server-side SDK. Public surface: Kilden::Client and
# Kilden::IdentitySigner — everything else is internal.
#
# The behavior of this SDK is specified, together with the other four server
# SDKs, in https://github.com/freshworkstudio/kilden-sdk-spec — changes that
# alter observable behavior land there first.
module Kilden
  # Raised only at construction time (spec contract 2): bad write key,
  # bad signer configuration. Nothing raises after construction.
  ConfigurationError = Class.new(ArgumentError)
end

require "kilden/version"
require "kilden/uuid"
require "kilden/canonical_json"
require "kilden/identity_signer"
require "kilden/transport"
require "kilden/sender"
require "kilden/event_queue"
require "kilden/hashing"
require "kilden/flag_cache"
require "kilden/client"
