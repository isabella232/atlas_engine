# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Dk
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "Danish addresses" do
          [
            # Unit number, standard format including a space
            [:dk, "Tietensgade 137, 2", [{ building_num: "137", street: "Tietensgade", unit_num: "2" }]],

            # Unit number with space omitted
            [:dk, "Tietensgade 137,2", [{ building_num: "137", street: "Tietensgade", unit_num: "2" }]],

            # Unit number with designator - currently does not distinguish between unit number and unit type
            [
              :dk,
              "Theodore roosevelts vej 19, 7. Tv",
              [{ building_num: "19", street: "Theodore roosevelts vej", unit_num: "7. Tv" }],
            ],

            # No unit number
            [:dk, "Tietensgade 137", [{ building_num: "137", street: "Tietensgade" }]],
          ].each do |country_code, input, expected|
            check_parsing(AddressParser, country_code, input, nil, expected)
          end
        end
      end
    end
  end
end
