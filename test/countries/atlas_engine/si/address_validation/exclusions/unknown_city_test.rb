# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module Si
    module AddressValidation
      module Exclusions
        class UnknownCityTest < ActiveSupport::TestCase
          include AtlasEngine::AddressValidation::AddressValidationTestHelper
          include AtlasEngine::AddressValidation::TokenHelper

          test "#apply? returns true when city comparison is poor" do
            rural_candidate_address = build_address(
              address1: "Belca",
              city: "Belca",
              country_code: "SI",
              zip: "4281",
            )
            candidate = candidate(rural_candidate_address)
            comparison = mock_address_comparison("Mojstrana", "Belca")
            assert UnknownCity.apply?(candidate, comparison)
          end

          test "#apply? returns false when city comparison is close" do
            rural_candidate_address = build_address(
              address1: "Moste",
              city: "Komenda",
              country_code: "SI",
              zip: "1218",
            )
            candidate = candidate(rural_candidate_address)
            comparison = mock_address_comparison("Komends", "Komenda")
            assert_not UnknownCity.apply?(candidate, comparison)
          end

          private

          def mock_address_comparison(given_city, candidate_city)
            given_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(given_city)
            candidate_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(candidate_city)
            city_comparison_result = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: given_sequence,
              right_sequence: candidate_sequence,
            ).compare

            city_comparison = typed_mock(AtlasEngine::AddressValidation::Validators::FullAddress::CityComparison)
            city_comparison.stubs(:sequence_comparison).returns(city_comparison_result)

            address_comparison = typed_mock(AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison)
            address_comparison.stubs(:city_comparison).returns(city_comparison)
            address_comparison
          end
        end
      end
    end
  end
end
