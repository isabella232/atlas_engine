# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Ch
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city] == ["Biel/Bienne"]
                  address[:city] += ["Bienne", "Biel"]
                elsif address[:city] == ["Emmenbrücke"]
                  address[:city] << "Emmen"
                elsif address[:city] == ["Effretikon"]
                  address[:city] << "Illnau-Effretikon"
                end
              end
            end
          end
        end
      end
    end
  end
end
