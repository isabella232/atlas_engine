# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Ch
    module Locales
      module Fr
        module ValidationTranscriber
          class AddressParserTest < ActiveSupport::TestCase
            include AtlasEngine::AddressValidation::AddressValidationTestHelper

            test "Swiss addresses written in French" do
              [
                # Unit number preceeding street
                [:ch, "798 Route de la Gruvaz", [{ building_num: "798", street: "Route de la Gruvaz" }]],
                # Unit number following street
                [:ch, "Rue Saint-Germain 3", [{ building_num: "3", street: "Rue Saint-Germain" }]],
              ].each do |country_code, input, expected|
                check_parsing(AddressParser, country_code, input, nil, expected)
              end
            end
          end
        end
      end
    end
  end
end
