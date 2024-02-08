# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Es
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "Street name and building number" do
          [
            [:es, "Calle San Juan 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan, 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan N 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan n54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan, N 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan número 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan Número 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan, número 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan n° 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan N° 54", [{ building_num: "54", street: "Calle San Juan" }]],
            [:es, "Calle San Juan, n° 54", [{ building_num: "54", street: "Calle San Juan" }]],
          ].each do |country_code, input, expected|
            check_parsing(AddressParser, country_code, input, nil, expected)
          end
        end

        test "Street name, building number, and additional info" do
          [
            [
              :es,
              "Avenida Antonio Belón 1, bloque Milenium 1 Atico A",
              [{ building_num: "1", street: "Avenida Antonio Belón" }],
            ],
            [:es, "Calle Arena 43, 2B", [{ building_num: "43", street: "Calle Arena" }]],
            [:es, "Av. 9 de octubre, 89 bajo (farmacia)", [{ building_num: "89", street: "Av. 9 de octubre" }]],
          ].each do |country_code, input, expected|
            check_parsing(AddressParser, country_code, input, nil, expected)
          end
        end
      end
    end
  end
end
