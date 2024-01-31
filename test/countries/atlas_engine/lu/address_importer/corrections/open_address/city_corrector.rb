# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Lu
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "Apply city aliases" do
              input_address = {
                source_id: "OA-1-0",
                locale: nil,
                country_code: "LU",
                province_code: "",
                region1: nil,
                city: ["Redange/Attert"],
                suburb: nil,
                zip: "1125",
                street: "Avenue Amélie",
                longitude: 10.6366,
                latitude: 44.6877,
                building_and_unit_ranges: { "2": {} },
              }

              expected = input_address.merge({
                city: ["Redange/Attert", "Redange", "Réiden", "Redange-sur-Attert"],
              })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
