# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Fo
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply replaces city with Nes when the city is Nes, Eysturoy or Nes, Vágur" do
              input_addresses = [
                { city: ["Nes, Eysturoy"] },
                { city: ["Nes, Vágur"] },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ city: ["Nes"] })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply replaces city with Syðradalur when the city is Syðradalur, Kalsoy or Syðradalur, Streymoy" do
              input_addresses = [
                { city: ["Syðradalur, Kalsoy"] },
                { city: ["Syðradalur, Streymoy"] },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ city: ["Syðradalur"] })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply does nothing for any other city" do
              input_address = { city: ["Hvítanes"] }

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
