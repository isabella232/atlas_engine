# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    module AddressImporter
      module Corrections
        module OpenAddress
          class PostalCodePlaceholderCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = PostalCodePlaceholderCorrector
            end

            test "#apply replaces 00-000 postal code with a nil" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "PL",
                country_code: "PL",
                province_code: "",
                region1: "",
                city: ["Kotowa Wola"],
                suburb: nil,
                zip: "00-000",
                street: "",
                building_and_unit_ranges: { "285" => {} },
              }

              expected = input_address.merge({ zip: nil })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply does not overwrite the zip otherwise" do
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
