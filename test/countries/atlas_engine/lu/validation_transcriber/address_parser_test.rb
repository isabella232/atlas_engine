# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Lu
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        test "One line addresses" do
          [
            [:lu, "4 Op den Aessen", [{ street: "Op den Aessen", building_num: "4" }]],
            [:lu, "4, Op den Aessen", [{ street: "Op den Aessen", building_num: "4" }]],
            [:lu, "Rue Winkel 5", [{ street: "Rue Winkel", building_num: "5" }]],
            [:lu, "21a rue des Bateliers", [{ street: "rue des Bateliers", building_num: "21a" }]],
            [:lu, "Maison 9A", [{ street: "Maison", building_num: "9A" }]],
            [:lu, "6/8 rue des Bains", [{ street: "rue des Bains", building_num: "6" }]],
            [:lu, "6-8 rue des Bains", [{ street: "rue des Bains", building_num: "6" }]],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line addresses" do
          [
            [:lu, "Maison", "101 Rue Du Cimetiere", [{ street: "Rue Du Cimetiere", building_num: "101" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AddressValidation::Address.new(**components)

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
