# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class EmptyStreetCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:street] == "" && address[:city].present?
                  # Many smaller rural towns in Poland don't have street names. Mailing addresses are
                  # often expressed as
                  # address1: <town name> <building number>
                  # city: <town name> OR <nearest postal town>
                  # postal_code: <postal code>
                  #
                  # The OpenAddresses dataset does not currently include county/postal town info.
                  address[:street] = Array(address[:city]).first
                end
              end
            end
          end
        end
      end
    end
  end
end
