# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Cz
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "Street name and standard building number" do
          expected = [{ street: "U Lužického semináře", building_num: "10" }]
          check_parsing(AddressParser, :cz, "U Lužického semináře 10", nil, expected, nil)
        end

        test "Street name and building number with slash" do
          expected = [{ street: "Králova", building_num: "816/20" }]
          check_parsing(AddressParser, :cz, "Králova 816/20", nil, expected, nil)
        end

        test "No street name" do
          [ # city name repeated in place of street
            [:cz, "Drnovice 250", [{ building_num: "250" }], { city: "Drnovice" }],
            [:cz, "250", [{ building_num: "250" }], { city: "Drnovice" }],
          ].each do |country_code, input, expected, components|
            check_parsing(AddressParser, country_code, input, nil, expected, components)
          end
        end
      end
    end
  end
end
