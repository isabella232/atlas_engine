# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Ch
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply appends the expected city alises" do
              input_addresses = [
                {
                  locale: "de",
                  country_code: "CH",
                  province_code: "LU",
                  zip: "6020",
                  city: ["Emmenbrücke"],
                  street: "Schönbühlstrasse",
                },
                {
                  locale: "de",
                  country_code: "CH",
                  province_code: "ZH",
                  zip: "8307",
                  city: ["Effretikon"],
                  street: "Im Langhag",
                },
                {
                  locale: "de",
                  country_code: "CH",
                  province_code: "BE",
                  zip: "2503",
                  city: ["Biel/Bienne"],
                  street: "Blumenrain",
                },
              ]

              expected_addresses = []
              expected_addresses << input_addresses[0].merge({ city: ["Emmenbrücke", "Emmen"] })
              expected_addresses << input_addresses[1].merge({ city: ["Effretikon", "Illnau-Effretikon"] })
              expected_addresses << input_addresses[2].merge({ city: ["Biel/Bienne", "Bienne", "Biel"] })

              input_addresses.each_with_index do |input_address, index|
                @klass.apply(input_address)

                assert_equal expected_addresses[index],
                  input_address,
                  "Expected #{input_address[:city]} to be #{expected_addresses[index][:city]}"
              end
            end

            test "apply does nothing for any other city" do
              input_address = {
                locale: "de",
                country_code: "CH",
                province_code: "BL",
                zip: "4147",
                city: ["Aesch BL"],
                street: "Pfeffingerstrasse",
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
