# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ProvinceCodeComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#sequence_comparison compares the session province with the candidate province field" do
            candidate = Candidate.new(
              id: "A",
              source: { "country_code" => "US", "province_code" => "TX" },
            )
            address = build_address(province_code: "US-TX", country_code: "US")
            datastore = Es::Datastore.new(address: address)

            province_code_comparison = ProvinceCodeComparison.new(address:, candidate:, datastore:)

            comparison = province_code_comparison.sequence_comparison

            assert_empty comparison.unmatched_tokens

            stubbed_sequence = Token::Sequence.from_string("US-TX")
            assert_equal stubbed_sequence, comparison.left_sequence
            assert_equal stubbed_sequence, comparison.right_sequence
          end

          test "#sequence_comparison handles US terriories " do
            candidate = AddressValidation::Candidate.new(
              id: "A",
              source: { "country_code" => "US", "province_code" => "PR" },
            )
            address = build_address(province_code: "US-PR", country_code: "US")
            datastore = Es::Datastore.new(address: address)

            province_code_comparison = ProvinceCodeComparison.new(address:, candidate:, datastore:)

            comparison = province_code_comparison.sequence_comparison

            assert_empty comparison.unmatched_tokens

            expected_sequence = Token::Sequence.from_string("PR")
            assert_equal expected_sequence, comparison.left_sequence
            assert_equal expected_sequence, comparison.right_sequence
          end
        end
      end
    end
  end
end
