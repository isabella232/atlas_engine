# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Fo
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city] == ["Nes, Eysturoy"] || address[:city] == ["Nes, Vágur"]
                  address[:city] = ["Nes"]
                elsif address[:city] == ["Syðradalur, Kalsoy"] || address[:city] == ["Syðradalur, Streymoy"]
                  address[:city] = ["Syðradalur"]
                end
              end
            end
          end
        end
      end
    end
  end
end
