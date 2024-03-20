# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Gg
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply appends Saint Samsaon as a city alias when the city is St. Sampson" do
              input_address = {
                source_id: "OA#4ae4366ebbdd85f4",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Sampson"],
                suburb: nil,
                zip: "GY2 4JT",
                street: "Les Grandes Maisons Road",
                longitude: -2.5236,
                latitude: 49.4773,
                building_and_unit_ranges: { "1": {}, "2": {}, "3": {}, "4": {} },
              }

              expected = input_address.merge({ city: ["St. Sampson", "Saint Samsaon"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Saint-Sauveur and Saint Sauveux as a city alias when the city is St. Saviour" do
              input_address = {
                source_id: "OA#8d5d6925013c6c8d",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Saviour"],
                suburb: nil,
                zip: "GY7 9FD",
                street: "Rue Des Choffins",
                longitude: -2.61233,
                latitude: 49.451,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["St. Saviour", "Saint-Sauveur", "Saint Sauveux"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Saint-Pierre Port as a city alias when the city is St. Peter Port" do
              input_address = {
                source_id: "OA#cc49acd69c6251e5",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Peter Port"],
                suburb: nil,
                zip: "GY1 1HZ",
                street: "Valnord Hill",
                longitude: -2.54502,
                latitude: 49.453,
                building_and_unit_ranges: { "3": {}, "5": {} },
              }

              expected = input_address.merge({ city: ["St. Peter Port", "Saint-Pierre Port"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Saint-André-de-la-Pommeraye and Saint Andri as a city alias when the city is St. Andrew" do
              input_address = {
                source_id: "OA#939ec9269c084208",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Andrew"],
                suburb: nil,
                zip: "GY6 8XZ",
                street: "Route Des Blicqs",
                longitude: -2.58425,
                latitude: 49.4412,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["St. Andrew", "Saint Andri", "Saint-André-de-la-Pommeraye"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends St. Peter's and  St. Pierre as a city alias when the city is St. Pierre Du Bois" do
              input_address = {
                source_id: "OA#e5026ecfbfe864b0",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Pierre Du Bois"],
                suburb: nil,
                zip: "GY7 9BY",
                street: "Route De Rocquaine",
                longitude: -2.65235,
                latitude: 49.4391,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["St. Pierre Du Bois", "St. Peter's", "St. Pierre"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Lé Casté and Sainte-Marie-du-Câtel as a city alias when the city is Castel" do
              input_address = {
                source_id: "OA#91742a2b0ff6bbb8",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["Castel"],
                suburb: nil,
                zip: "GY5 7JZ",
                street: "Les Grands Moulins",
                longitude: -2.61114,
                latitude: 49.4581,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["Castel", "Lé Casté", "Sainte-Marie-du-Câtel"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Le Fôret and La Fouarêt as a city alias when the city is Forest" do
              input_address = {
                source_id: "OA#a716ca3ada636137",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["Forest"],
                suburb: nil,
                zip: "GY8 0DW",
                street: "Rue Des Landes",
                longitude: -2.5993,
                latitude: 49.4304,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["Forest", "Le Fôret", "La Fouarêt"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Tortévas as a city alias when the city is Torteval" do
              input_address = {
                source_id: "OA#bcea04d9bbecd9c3",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["Torteval"],
                suburb: nil,
                zip: "GY8 0PW",
                street: "Clos Des Quatre Saisons",
                longitude: -2.65803,
                latitude: 49.4337,
                building_and_unit_ranges: { "1": {}, "2": {}, "3": {}, "4": {} },
              }

              expected = input_address.merge({ city: ["Torteval", "Tortévas"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply appends Lé Vale and Le Valle as a city alias when the city is Vale" do
              input_address = {
                source_id: "OA#a6dc3cbb848187e6",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["Vale"],
                suburb: nil,
                zip: "GY6 8BD",
                street: "Route De La Hougue Du Pommier",
                longitude: -2.57599,
                latitude: 49.4785,
                building_and_unit_ranges: {},
              }

              expected = input_address.merge({ city: ["Vale", "Lé Vale", "Le Valle"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for any other city" do
              input_address = {
                source_id: "OA#8928534ee247bcf0",
                locale: "",
                country_code: "GG",
                province_code: "",
                region1: "",
                city: ["St. Martin"],
                suburb: nil,
                zip: "GY4 6AS",
                street: "Calais",
                longitude: 49.4325,
                latitude: -2.53843,
              }

              expected = input_address

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
