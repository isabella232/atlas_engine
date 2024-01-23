# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Cz
    class AddressParserTest < ActiveSupport::TestCase
      include ValidationTranscriber

      test "Street name and standard building number" do
        expected = [{ street: "U Lužického semináře", building_num: "10" }]
        check_parsing(:cz, "U Lužického semináře 10", nil, expected, nil)
      end

      test "Street name and building number with slash" do
        expected = [{ street: "Králova", building_num: "816/20" }]
        check_parsing(:cz, "Králova 816/20", nil, expected, nil)
      end

      test "No street name" do
        [ # city name repeated in place of street
          [:cz, "Drnovice 250", [{ building_num: "250" }], { city: "Drnovice" }],
          [:cz, "250", [{ building_num: "250" }], { city: "Drnovice" }],
        ].each do |country_code, input, expected, components|
          check_parsing(country_code, input, nil, expected, components)
        end
      end

      private

      def check_parsing(country_code, address1, address2, expected, components = nil)
        components ||= {}
        components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
        address = AtlasEngine::AddressValidation::Address.new(**components)

        actual = ValidationTranscriber::AddressParser.new(address: address).parse

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
