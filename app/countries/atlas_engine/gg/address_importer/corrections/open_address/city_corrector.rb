# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              CITY_ALIASES_MAPPING = {
                "St. Sampson" => ["Saint Samsaon"],
                "St. Saviour" => ["Saint-Sauveur", "Saint Sauveux"],
                "St. Peter Port" => ["Saint-Pierre Port"],
                "St. Andrew" => ["Saint Andri", "Saint-André-de-la-Pommeraye"],
                "St. Pierre Du Bois" => ["St. Peter's", "St. Pierre"],
                "Castel" => ["Lé Casté", "Sainte-Marie-du-Câtel"],
                "Forest" => ["Le Fôret", "La Fouarêt"],
                "Torteval" => ["Tortévas"],
                "Vale" => ["Lé Vale", "Le Valle"],
              }

              sig { params(address: Hash).void }
              def apply(address)
                city = address[:city].first
                if CITY_ALIASES_MAPPING.include?(city)
                  address[:city] += CITY_ALIASES_MAPPING[city]
                end
              end
            end
          end
        end
      end
    end
  end
end
