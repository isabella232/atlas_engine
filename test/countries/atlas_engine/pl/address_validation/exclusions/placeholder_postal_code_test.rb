# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Pl
    module AddressValidation
      module Exclusions
        class PlaceholderPostalCodeTest < ActiveSupport::TestCase
          include AtlasEngine::AddressValidation::AddressValidationTestHelper

          test "#apply? returns true when candidate has placeholder zip" do
            candidate_address = build_address(
              address1: "Artyleryjska",
              city: "Bolesławiec",
              country_code: "PL",
              zip: "00-000",
            )
            candidate = candidate(candidate_address)
            assert PlaceholderPostalCode.apply?(candidate, mock_address_comparison)
          end

          test "#apply? returns false otherwise" do
            address = build_address(
              address1: "Artyleryjska",
              city: "Bolesławiec",
              country_code: "PL",
              zip: "59-700",
            )
            candidate = candidate(address)
            assert_not PlaceholderPostalCode.apply?(candidate, mock_address_comparison)
          end

          private

          def mock_address_comparison
            typed_mock(AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison)
          end
        end
      end
    end
  end
end
