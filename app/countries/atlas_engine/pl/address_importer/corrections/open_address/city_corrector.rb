# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city] == ["Warszawa"]
                  address[:city] << "Warsaw"
                end
              end
            end
          end
        end
      end
    end
  end
end
