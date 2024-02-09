# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class StreetComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#sequence_comparison compares the session street sequences with the candidate street sequences" do
            candidate = Candidate.new(id: "A", source: { "street" => "County Road 34" })
            address = build_address(address1: "1234 County Road 34", country_code: "US")
            datastore = Es::Datastore.new(address: address)
            input_street_sequences = [Token::Sequence.from_string(address.address1)]
            datastore.street_sequences = input_street_sequences

            street_comparison = StreetComparison.new(address:, candidate:, datastore:, component: :street)

            comparison = street_comparison.sequence_comparison
            candidate_street_sequences = candidate.component(:street).sequences

            comparisons = comparison.token_comparisons
            i_1234, i_county, i_road, i_34 = input_street_sequences.first.tokens
            c_county, c_road, c_34 = candidate_street_sequences.first.tokens

            assert_equal [i_1234], comparison.unmatched_tokens
            assert_equal ["County Road 34"], candidate_street_sequences.map(&:raw_value)
            assert_equal input_street_sequences.first, comparison.left_sequence
            assert_equal candidate_street_sequences.first, comparison.right_sequence
            assert_comparison(i_county, :equal, c_county, comparisons[0])
            assert_comparison(i_road, :equal, c_road, comparisons[1])
            assert_comparison(i_34, :equal, c_34, comparisons[2])
          end
        end
      end
    end
  end
end
