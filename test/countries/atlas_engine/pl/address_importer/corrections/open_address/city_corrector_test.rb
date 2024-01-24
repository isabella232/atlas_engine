# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply appends Warsaw as city alias when city is Warszawa" do
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

              expected = input_address.merge({ city: ["Warszawa", "Warsaw"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for any other city" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "PL",
                country_code: "PL",
                province_code: "",
                region1: "",
                city: ["Trzebnica"],
                suburb: nil,
                zip: "55-100",
                street: "Wrocławska",
                building_and_unit_ranges: { "8D" => {} },
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
