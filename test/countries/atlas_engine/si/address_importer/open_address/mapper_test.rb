# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Si
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" => {
                "hash" => "98dffba6de18223e",
                "number" => "1",
                "street" => "Cankarjev trg",
                "unit" => "",
                "city" => "Ajdovščina",
                "district" => "Ajdovščina",
                "region" => "Goriška",
                "postcode" => "5270",
                "id" => "11028489",
              },
              "geometry" => { "type" => "Point", "coordinates" => [13.9095556, 45.8873882] },
            }
            @klass = Mapper.new(country_code: "SI")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
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

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
