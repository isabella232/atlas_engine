# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class PostalCodePlaceholderCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:zip] == "00-000"
                  address[:zip]  = nil
                end
              end
            end
          end
        end
      end
    end
  end
end
