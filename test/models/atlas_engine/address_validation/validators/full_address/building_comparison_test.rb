# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class BuildingComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#compare compares the session building number with the candidate building number ranges" do
            candidate = Candidate.new(
              id: "A",
              source: { "building_and_unit_ranges" => "{\"(0..99)/1\": {}}" },
            )
            address = build_address(country_code: "CA", address1: "1 Main St")
            datastore = Es::Datastore.new(address: address)

            building_comparison = BuildingComparison.new(address:, candidate:, datastore:)

            comparison = building_comparison.compare

            assert comparison.match?
          end
        end
      end
    end
  end
end
