# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Gg
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class CityTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              test "#apply? returns true when candidate city is present in sesssion address components" do
                address = build_address(
                  address1: "43 Mount Row, St. Peter Port",
                  city: "",
                  country_code: "GG",
                  zip: "GY1 1NU",
                )

                candidate_address = candidate(
                  building_num: "43",
                  street: "Mount Row",
                  city: ["St. Peter Port"],
                  country_code: "GG",
                  zip: "GY1 1NU",
                )

                comparison = mock_address_comparison(address, "St. Peter Port", "St. Peter Port")

                assert City.apply?(candidate_address, comparison)
              end

              test "#apply? returns false when candidate city is NOTpresent in sesssion address components" do
                address = build_address(
                  address1: "43 Mount Row",
                  city: "St. Peter Port",
                  country_code: "GG",
                  zip: "GY1 1NU",
                )

                candidate_address = candidate(
                  building_num: "43",
                  street: "Mount Row",
                  city: ["St. Peter Port"],
                  country_code: "GG",
                  zip: "GY1 1NU",
                )

                comparison = mock_address_comparison(address, "St. Peter Port", "St. Peter Port")

                assert_not City.apply?(candidate_address, comparison)
              end

              def mock_address_comparison(session_address, given_city, candidate_city)
                given_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(given_city)
                candidate_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(candidate_city)
                city_comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
                  left_sequence: given_sequence,
                  right_sequence: candidate_sequence,
                ).compare

                address_comparison = typed_mock(
                  AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
                )
                address_comparison.stubs(:city_comparison).returns(city_comparison)

                parsings = parsings_for(session_address)
                address_comparison.stubs(:parsings).returns(parsings)
                address_comparison.stubs(:address).returns(session_address)
                address_comparison
              end
            end
          end
        end
      end
    end
  end
end
