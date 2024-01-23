# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Bm
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityAliasCorrector
            class << self
              extend T::Sig

              BM_PARISH_AND_CITY_NAMES = {
                "City of Hamilton" => ["City of Hamilton", "Hamilton"],
                "Devonshire" => ["Devonshire Parish", "Devonshire"],
                "Hamilton" => ["Hamilton Parish", "Hamilton"],
                "Paget" => ["Paget Parish", "Paget"],
                "Pembroke" => ["Pembroke Parish", "Pembroke"],
                "Sandys" => ["Sandys Parish", "Sandys"],
                "Smiths" => ["Smiths Parish", "Smiths"],
                "Southampton" => ["Southampton Parish", "Southampton"],
                "St. George's" => ["St. George's Parish", "St. George's"],
                "Town of St. George" => ["Town of St. George", "St. George"],
                "Warwick" => ["Warwick Parish", "Warwick"],
              }.freeze

              sig { params(address: Hash).void }
              def apply(address)
                if BM_PARISH_AND_CITY_NAMES.key?(address[:city][0])
                  address[:city] = BM_PARISH_AND_CITY_NAMES[address[:city][0]]
                end
              end
            end
          end
        end
      end
    end
  end
end
