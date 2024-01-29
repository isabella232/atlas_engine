# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module AddressImporter
      module OpenAddress
        module Corrections
          class CityDistrictCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:region4].present?
                  address[:city] << address[:region4] if address[:city].exclude?(address[:region4])
                end
              end
            end
          end
        end
      end
    end
  end
end
