# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Si
    module AddressImporter
      module OpenAddress
        module Corrections
          class CityDistrictCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityDistrictCorrector
            end

            test "#apply appends region4 to city array when different from all other aliases" do
              input_address = {
                source_id: "OA-13238383",
                locale: nil,
                country_code: "SI",
                province_code: nil,
                region1: "Osrednjeslovenska",
                region4: "Brezovica",
                city: ["Podplešivica"],
                suburb: nil,
                zip: "1357",
                street: "Podplešivica",
                building_and_unit_ranges: { "30" => {} },
              }

              expected = input_address.merge({ city: ["Podplešivica", "Brezovica"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply does nothing when region4 is blank" do
              input_address = {
                source_id: "OA-13238383",
                locale: nil,
                country_code: "SI",
                province_code: nil,
                region1: "Osrednjeslovenska",
                region4: nil,
                city: ["Podplešivica"],
                suburb: nil,
                zip: "1357",
                street: "Podplešivica",
                building_and_unit_ranges: { "30" => {} },
              }

              expected = input_address.dup

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply does nothing when region4 is already included in city aliases" do
              input_address = {
                source_id: "OA-11028489",
                locale: nil,
                country_code: "SI",
                province_code: nil,
                region1: "Goriška",
                region4: "Ajdovščina",
                city: ["Ajdovščina"],
                suburb: nil,
                zip: "5270",
                street: "Cankarjev trg",
                building_and_unit_ranges: { "1" => {} },
                latitude: 45.8873882,
                longitude: 13.9095556,
              }

              expected = input_address.dup

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
