# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module It
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class CityTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              test "#apply? returns true" do
                address = build_address(
                  address1: "Via dei Palustei 23",
                  city: "Meano",
                  province_code: "TN",
                  country_code: "IT",
                  zip: "38121",
                )
                assert City.apply?(candidate(address), mock_address_comparison)
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
  end
end
