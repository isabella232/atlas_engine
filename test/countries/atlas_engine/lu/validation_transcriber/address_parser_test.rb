# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Lu
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "One line addresses" do
          [
            [:lu, "4 Op den Aessen", [{ street: "Op den Aessen", building_num: "4" }]],
            [:lu, "4, Op den Aessen", [{ street: "Op den Aessen", building_num: "4" }]],
            [:lu, "Rue Winkel 5", [{ street: "Rue Winkel", building_num: "5" }]],
            [:lu, "21a rue des Bateliers", [{ street: "rue des Bateliers", building_num: "21a" }]],
            [:lu, "Maison 9A", [{ street: "Maison", building_num: "9A" }]],
            [:lu, "6/8 rue des Bains", [{ street: "rue des Bains", building_num: "6" }]],
            [:lu, "6-8 rue des Bains", [{ street: "rue des Bains", building_num: "6" }]],
          ].each do |country_code, address1, expected|
            check_parsing(AddressParser, country_code, address1, nil, expected)
          end
        end

        test "Two line addresses" do
          [
            [:lu, "Maison", "101 Rue Du Cimetiere", [{ street: "Rue Du Cimetiere", building_num: "101" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end
      end
    end
  end
end
