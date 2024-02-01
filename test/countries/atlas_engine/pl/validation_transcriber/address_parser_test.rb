# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Pl
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "#parse returns the correct address components for a PL address" do
          check_parsing(
            AddressParser,
            :pl,
            "ul. Rokicińska 117",
            nil,
            [{ street: "ul. Rokicińska", building_num: "117" }],
          )
        end

        test "#parse treats nr as a separator between street and building number" do
          check_parsing(
            AddressParser,
            :pl,
            "Armii Krajowej nr 54",
            nil,
            [{ street: "Armii Krajowej", building_num: "54" }],
          )
        end

        test "#parse finds a dot not followed by a space, replaces dot with a space" do
          [
            [:pl, "Al.Armii Krajowej 54", nil, [{ street: "Al Armii Krajowej", building_num: "54" }]],
            [:pl, "pl.Armii Krajowej 54", nil, [{ street: "pl Armii Krajowej", building_num: "54" }]],
            [:pl, "UL.Armii Krajowej 54", nil, [{ street: "UL Armii Krajowej", building_num: "54" }]],
            [:pl, "Al. Armii Krajowej 54", nil, [{ street: "Al. Armii Krajowej", building_num: "54" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end

        test "#parse separates building number from unit number on single address line" do
          [
            [:pl, "Biegusa 74/44", nil, [{ street: "Biegusa", building_num: "74", unit_num: "44" }]],
            [:pl, "Krucza 32 m. 44", nil, [{ street: "Krucza", building_num: "32", unit_num: "44" }]],
            [:pl, "ul. Górna Wilda 74 /63", nil, [{ street: "ul. Górna Wilda", building_num: "74", unit_num: "63" }]],
            [:pl, "Lewicka 14 m 2", nil, [{ street: "Lewicka", building_num: "14", unit_num: "2" }]],
            [:pl, "Kowalska 12 / 104", nil, [{ street: "Kowalska", building_num: "12", unit_num: "104" }]],
            [:pl, "Reymonta 12-14", nil, [{ street: "Reymonta", building_num: "12", unit_num: "14" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end
      end
    end
  end
end
