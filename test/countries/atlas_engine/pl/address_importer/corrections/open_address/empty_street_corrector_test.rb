# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class EmptyStreetCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = EmptyStreetCorrector
            end

            test "#apply copies city name into street field when street is empty string" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "PL",
                country_code: "PL",
                province_code: "",
                region1: "",
                city: ["Kotowa Wola"],
                suburb: nil,
                zip: "37-415",
                street: "",
                building_and_unit_ranges: { "285" => {} },
              }

              expected = input_address.merge({ street: "Kotowa Wola" })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply does not copy a blank city name" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "PL",
                country_code: "PL",
                province_code: "",
                region1: "",
                city: [""],
                suburb: nil,
                zip: "37-415",
                street: "",
                building_and_unit_ranges: { "285" => {} },
              }

              expected = input_address.dup

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply does not overwrite the street name when already present" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "PL",
                country_code: "PL",
                province_code: "",
                region1: "",
                city: ["Warszawa"],
                suburb: nil,
                zip: "03-938",
                street: "Zwycięzców",
                building_and_unit_ranges: { "40" => {} },
              }

              expected = input_address.dup

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
