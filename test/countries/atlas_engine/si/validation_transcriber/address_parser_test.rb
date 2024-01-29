# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Si
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        test "#parse returns the correct address components for a SI address" do
          [
            [:si, "Šarhova ulica 77", nil, [{ street: "Šarhova ulica", building_num: "77" }]],
            [:si, "Šared 32d", nil, [{ street: "Šared", building_num: "32d" }]],
            [:si, "Prapreče - Del 5a", nil, [{ street: "Prapreče - Del", building_num: "5a" }]],
            [:si, "Kidričeva Cesta 27 C", nil, [{ street: "Kidričeva Cesta", building_num: "27 C" }]],
            [:si, "Metoda mikuža, 12", nil, [{ street: "Metoda mikuža", building_num: "12" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        test "#parse finds a dot not followed by a space, replaces dot with a space" do
          [
            [:si, "Zg.prapreče 9", nil, [{ street: "Zg prapreče", building_num: "9" }]],
            [:si, "C. Staneta Žagarja 7", nil, [{ street: "C. Staneta Žagarja", building_num: "7" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AtlasEngine::AddressValidation::Address.new(**components)

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
