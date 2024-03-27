# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Gg
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for GG loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("GG").validation.address_parser)
        end

        test "Parses one line Guernsey addresses" do
          [
            [
              :gg,
              "La Boue Farmhouse",
              [{ building_name: "La Boue Farmhouse" }],
            ],
            [
              :gg,
              "Donegal, Pleinmont Road, St Peter's",
              [{ building_name: "Donegal", street: "Pleinmont Road", city: "St Peter's" }],
            ],
            [
              :gg,
              "Apartment 15, La Charrotterie Mills, St Peter's Port",
              [{
                unit_type: "Apartment",
                unit_num: "15",
                building_name: "La Charrotterie Mills",
                city: "St Peter's Port",
              }],
            ],
            [
              :gg,
              "7 Victoria Street",
              [{ street: "Victoria Street", building_num: "7" }],
            ],
            [
              :gg,
              "La Bouvee Farm Cottage La Bouvee, St. Martins",
              [{ building_name: "La Bouvee Farm Cottage La Bouvee", city: "St. Martins" }],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Guernsey addresses" do
          [
            [
              :gg,
              "Lavender Lodge",
              "St Peter port",
              [
                { building_name: "Lavender Lodge" },
                { city: "St Peter port" },
              ],
            ],
            [
              :gg,
              "Lavender Lodge",
              "saint sauveur",
              [
                { building_name: "Lavender Lodge" },
                { city: "saint sauveur" },
              ],
            ],
            [
              :gg,
              "Menerbes, La Grande Rue",
              "St. Saviour",
              [

                { city: "St. Saviour" },
                { building_name: "Menerbes", street: "La Grande Rue" },

              ],
            ],
            [
              :gg,
              "Les Sages de Bas",
              "Les Sages",
              [

                { building_name: "Les Sages de Bas" },
                { street: "Les Sages" },

              ],
            ],
            [
              :gg,
              "19 Victoria Road",
              "St Peter Port",
              [

                { building_num: "19", street: "Victoria Road" },
                { city: "St Peter Port" },

              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        test "Two Guernsey addresses with accents" do
          [
            [
              :gg,
              "Lavender Lodge",
              "Lé Casté",
              [
                { building_name: "Lavender Lodge" },
                { city: "Lé Casté" },
              ],
            ],
            [
              :gg,
              "Lavender Lodge",
              "Le Caste",
              [
                { building_name: "Lavender Lodge" },
                { city: "Le Caste" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AtlasEngine::AddressValidation::Address.new(**components)

          actual = AddressParser.new(address: address).parse

          assert(
            expected.to_set.subset?(actual.to_set),
            "For input ( address1: #{address1.inspect}, address2: #{address2.inspect} )\n\n " \
              "#{expected.inspect} \n\n" \
              "Must be included in: \n\n" \
              "#{actual.inspect}",
          )
        end
      end
    end
  end
end
