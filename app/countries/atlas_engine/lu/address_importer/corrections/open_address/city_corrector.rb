# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Lu
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              # NOTE: ensure keys match the city names we have in our db
              CITY_ALIASES = {
                "luxembourg" => ["Lëtzebuerg"],
                "esch-sur-alzette" => ["Esch-Uelzecht", "Esch/Alzette"],
                "dudelange" => ["Diddeleng", "Düdelingen"],
                "schifflange" => ["Schëffleng"],
                "bettembourg" => ["Beetebuerg"],
                "pétange" => ["Péiteng"],
                "ettelbruck" => ["Ettelbréck"],
                "diekirch" => ["Dikrech"],
                "strassen" => ["Stroossen"],
                "bertrange" => ["Bartreng"],
                "belvaux" => ["Bieles"],
                "differdange" => ["Déifferdeng"],
                "wiltz" => ["Wolz"],
                "grevenmacher" => ["Gréiwemaacher"],
                "mersch" => ["Miersch"],
                "redange/attert" => ["Redange", "Réiden", "Redange-sur-Attert"],
              }

              sig { params(address: Hash).void }
              def apply(address)
                city = address[:city].first.downcase
                aliases = CITY_ALIASES[city.downcase] || []
                address[:city] = address[:city] + aliases
              end
            end
          end
        end
      end
    end
  end
end
