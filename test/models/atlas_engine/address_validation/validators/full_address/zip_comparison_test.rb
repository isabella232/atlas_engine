# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ZipComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#sequence_comparison compares the session zip with the candidate zip field" do
            candidate = Candidate.new(id: "A", source: { "zip" => "J9A 2V2" })
            address = build_address(country_code: "CA", zip: "j9a2v2")
            datastore = Es::Datastore.new(address: address)

            zip_comparison = ZipComparison.new(address:, candidate:, datastore:)

            comparison = zip_comparison.sequence_comparison
            candidate_zip_sequences = candidate.component(:zip).sequences

            assert_predicate comparison, :match?
            assert_equal ["J9A 2V2"], candidate_zip_sequences.map(&:raw_value)
            assert_equal ["j9a", "2v2"], comparison.left_sequence.tokens.map(&:value)
            assert_equal candidate_zip_sequences.first, comparison.right_sequence
          end

          test "#sequence_comparison compares the session zip with a truncated candidate zip field when applicable" do
            candidate = Candidate.new(id: "A", source: { "zip" => "S2919 BNA" })
            address = build_address(country_code: "AR", zip: "S2919")
            datastore = Es::Datastore.new(address: address)

            zip_comparison = ZipComparison.new(address:, candidate:, datastore:)

            comparison = zip_comparison.sequence_comparison

            candidate.component(:zip).value = "S2919"
            expected_candidate_zip_sequences = candidate.component(:zip).sequences

            assert_predicate comparison, :match?
            assert_equal ["S2919"], expected_candidate_zip_sequences.map(&:raw_value)
            assert_equal ["s2919"], comparison.left_sequence.tokens.map(&:value)
            assert_equal expected_candidate_zip_sequences.first, comparison.right_sequence
          end

          test "#sequence_comparison returns nil comparison for candidate when there is no field value to compare" do
            candidate = Candidate.new(id: "A", source: { "zip" => nil })
            address = build_address(country_code: "CA", zip: "j9a2v2")
            datastore = Es::Datastore.new(address: address)

            zip_comparison = ZipComparison.new(address:, candidate:, datastore:)

            comparison = zip_comparison.sequence_comparison
            candidate_zip_sequences = candidate.component(:zip).sequences

            assert_nil comparison
            assert_empty candidate_zip_sequences.map(&:raw_value)
          end
        end
      end
    end
  end
end
