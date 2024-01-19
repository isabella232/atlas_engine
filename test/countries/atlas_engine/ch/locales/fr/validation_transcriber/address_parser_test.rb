# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Ch
    module Locales
      module Fr
        class AddressParserTest < ActiveSupport::TestCase
          include ValidationTranscriber

          test "Swiss addresses written in French" do
            [
              # Unit number preceeding street
              [:ch, "798 Route de la Gruvaz", [{ building_num: "798", street: "Route de la Gruvaz" }]],
              # Unit number following street
              [:ch, "Rue Saint-Germain 3", [{ building_num: "3", street: "Rue Saint-Germain" }]],
            ].each do |country_code, input, expected|
              check_parsing(country_code, input, nil, expected)
            end
          end

          private

          def check_parsing(country_code, address1, address2, expected, components = nil)
            components ||= {}
            components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
            address = AddressValidation::Address.new(**components)

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
  end
end
