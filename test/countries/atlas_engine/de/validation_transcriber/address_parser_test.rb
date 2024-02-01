# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module De
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "German addresses" do
          [
            # No unit number
            [:de, "Hauptstraße 137", [{ building_num: "137", street: "Hauptstraße" }]],
          ].each do |country_code, input, expected|
            check_parsing(AddressParser, country_code, input, nil, expected)
          end
        end
      end
    end
  end
end
