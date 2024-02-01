# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Be
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "One line addresses" do
          [
            # standard format with building number
            [:be, "De Hees 17", [{ street: "De Hees", building_num: "17" }]],
            # standard format with building number attached to Unit number
            [:be, "Rue de la Bruyère 11A", [{ street: "Rue de la Bruyère", building_num: "11A" }]],
            # building number incorrectly added before street name
            [:be, "12 Rue Capitaine Crespel", [{ street: "Rue Capitaine Crespel", building_num: "12" }]],

            # building number incorrectly added before street name, with punctuation
            [:be, "13,Rue Henri Boussingault", [{ street: "Rue Henri Boussingault", building_num: "13" }]],
            [:be, "14, Rue Henri Boussingault", [{ street: "Rue Henri Boussingault", building_num: "14" }]],
            [:be, "15 , Rue Henri Boussingault", [{ street: "Rue Henri Boussingault", building_num: "15" }]],
            [:be, "16A Rue Henri Boussingault", [{ street: "Rue Henri Boussingault", building_num: "16A" }]],

            # street has accented character
            [:be, "Burgemeester Françoisplein 17", [{ street: "Burgemeester Françoisplein", building_num: "17" }]],
            # building number with a slash separating unit number
            [:be, "Hubert Lampolaan 36/101", [{ street: "Hubert Lampolaan", building_num: "36", unit_num: "101" }]],
            # building number with a slash separating po box number
            [:be, "Bermbeekstraat 23/bus 1", [{ street: "Bermbeekstraat", building_num: "23", po_box: "1" }]],
            # building number always starts with a digit
            [:be, "Langbroekerdijk A 39", [{ street: "Langbroekerdijk A", building_num: "39" }]],
            # building and unit number separated by comma
            [:be, "Spankerenseweg 34, H", [{ street: "Spankerenseweg", building_num: "34", unit_num: "H" }]],
            # alphanumeric building number (the letter is likely a unit number, but we don't care)
            [:be, "Van Woustraat 165h", [{ street: "Van Woustraat", building_num: "165h" }]],
            # spaces between street, building and unit number
            [
              :be,
              "Juliana Van Stolberglaan 116 109",
              [
                { street: "Juliana Van Stolberglaan 116", building_num: "109" },
                { street: "Juliana Van Stolberglaan", building_num: "116", unit_num: "109" },
              ],
            ],
            # dash in street name
            [:be, "Aletta Jacobs-erf 168", [{ street: "Aletta Jacobs-erf", building_num: "168" }]],
            # dash between building number and unit number
            [:be, "Orteliuskade 27-I", [{ street: "Orteliuskade", building_num: "27", unit_num: "I" }]],
            # numbered street with building number. bad format leads to bad interpretation
            [:be, "Kogge 08-53", [{ street: "Kogge", building_num: "08", unit_num: "53" }]],
            # street named Singel with building number and unit number
            [:be, "Singel 213-1", [{ street: "Singel", building_num: "213", unit_num: "1" }]],
            # street having dash in name (some streets contain year ranges)
            [
              :be,
              "Singel 40-45 219",
              [
                { street: "Singel 40-45", building_num: "219" },
              ],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(AddressParser, country_code, address1, nil, expected)
          end
        end

        test "Two line addresses" do
          [
            # building number on address2
            [:be, "Op de Peelberg", "22", [{ street: "Op de Peelberg", building_num: "22" }]],
            # building number and unit number on address2
            [:be, "Kerkveld", "8-1", [{ street: "Kerkveld", building_num: "8", unit_num: "1" }]],
            # numbered street with building number, unit on address2
            [
              :be,
              "Juliana Van Stolberglaan 116",
              "109",
              [
                { street: "Juliana Van Stolberglaan 116", building_num: "109" },
                { street: "Juliana Van Stolberglaan", building_num: "116", unit_num: "109" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end

        test "Isolates post office boxes" do
          [
            [:be, "Rue de la Senne 32 box 20", nil, [{ street: "Rue de la Senne", building_num: "32", po_box: "20" }]],
            [:be, "Veste 15 - boite 01", nil, [{ street: "Veste", building_num: "15", po_box: "01" }]],
            [:be, "Postbus 123", nil, [{ po_box: "123" }]],
            [:be, "PB 12345", nil, [{ po_box: "12345" }]],
            [:be, "Antwoordnummer 123", nil, [{ po_box: "123" }]],
            [
              :be,
              "Hoofdstraat 12, Postbus 1234",
              nil,
              [{ street: "Hoofdstraat", building_num: "12", po_box: "1234" }],
            ],
            [
              :be,
              "Hoofdstraat 12",
              "Postbus 1234",
              [{ street: "Hoofdstraat", building_num: "12", po_box: "1234" }],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end
      end
    end
  end
end
