# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"
require "helpers/atlas_engine/log_assertion_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CandidateResultTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper
          include LogAssertionHelper

          def setup
            @matching_strategy = AddressValidation::MatchingStrategies::EsStreet
          end

          test "always adds serialized candidate to result" do
            @address = address
            result = result()
            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal ",ON,,,,K2P 1L4,Ottawa,,Elgin Street", result.candidate
          end

          test "does not modify result concerns when candidate and address are a match" do
            @address = address
            result = result()

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal AddressValidation::Result::SORTED_VALIDATION_SCOPES, result.validation_scope
            assert_empty result.concerns
            assert_empty result.suggestions
          end

          test "does not modify result concerns when candidate and address have a match in multiple array values" do
            @address = address(city: "Orleans")
            result = result()
            address_comparison = address_comparison(city: ["Nepean", "Orleans", "Barrhaven"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal AddressValidation::Result::SORTED_VALIDATION_SCOPES, result.validation_scope
            assert_empty result.concerns
            assert_empty result.suggestions
          end

          test "selects the closest matching value if the input has an edit distance of 2 from an accepted value" do
            @address = address(city: "Orlayans")
            result = result()
            address_comparison = address_comparison(city: ["Nepean", "Orleans", "Barrhaven"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            suggestion = result.suggestions.first
            expected_suggestion_attributes = {
              id: suggestion.id,
              address1: nil,
              address2: nil,
              city: "Orleans",
              zip: nil,
              province_code: nil,
              province: nil,
              country_code: nil,
            }
            assert_equal expected_suggestion_attributes, suggestion.attributes
          end

          test "selects the first value in the array if the user input has over 2 edit distance from the accepted values" do
            @address = address(city: "OrleaNNNns")
            result = result()
            address_comparison = address_comparison(city: ["Nepean", "Orleans", "Barrhaven"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            suggestion = result.suggestions.first
            expected_suggestion_attributes = {
              id: suggestion.id,
              address1: nil,
              address2: nil,
              city: "Nepean",
              zip: nil,
              province_code: nil,
              province: nil,
              country_code: nil,
            }
            assert_equal expected_suggestion_attributes, suggestion.attributes
          end

          test "selects the closest match within the accepted values" do
            @address = address(city: "Barrheaven")
            result = result()
            address_comparison = address_comparison(city: ["Nepean", "Orleans", "Barrhaven"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            suggestion = result.suggestions.first
            expected_suggestion_attributes = {
              id: suggestion.id,
              address1: nil,
              address2: nil,
              city: "Barrhaven",
              zip: nil,
              province_code: nil,
              province: nil,
              country_code: nil,
            }
            assert_equal expected_suggestion_attributes, suggestion.attributes
          end

          test "always adds serialized candidate to result even when request is missing a field" do
            default_address = {
              phone: "613-555-1867",
              address1: "150 Elgin Street",
              city: "Ottawa",
              zip: "K2P 1L4",
              province_code: "ON",
              province: "Ontario",
              country_code: "CA",
            }

            # this request is missing the address2 field
            @address = Types::AddressValidation::AddressInput.from_hash(
              {
                address1: default_address[:address1],
                city: default_address[:city],
                province_code: default_address[:province_code],
                zip: default_address[:zip],
                country_code: default_address[:country_code],
                phone: default_address[:phone],
              },
            )

            result = result()
            # this simulates a discrepancy which would require us to build a suggestion
            address_comparison = address_comparison(city: ["Nepean"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            suggestion = result.suggestions.first
            expected_suggestion_attributes = {
              id: suggestion.id,
              address1: nil,
              address2: nil,
              city: "Nepean",
              zip: nil,
              province_code: nil,
              province: nil,
              country_code: nil,
            }
            assert_equal expected_suggestion_attributes, suggestion.attributes
          end

          test "adds a suggestion with two corrected attributes when ConcernBuilder.should_suggest? is true and two fields don't match" do
            ConcernBuilder.expects(:should_suggest?).once.returns(true)
            @address = address
            result = result()
            address_comparison = address_comparison(city: ["Nepean"], province_code: "AB")

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            suggestion = result.suggestions.first
            assert_equal "Nepean", suggestion.attributes[:city]
            assert_equal "AB", suggestion.attributes[:province_code]
          end

          test "adds concerns with the same suggestion when ConcernBuilder.should_suggest? is true and fields don't match" do
            ConcernBuilder.expects(:should_suggest?).once.returns(true)
            @address = address
            result = result()
            address_comparison = address_comparison(zip: "K2L 1P4", province_code: "AB")

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.suggestions.size
            assert_equal 2, result.concerns.size

            province_concern = result.concerns.find { |c| :province_inconsistent == c.code }
            assert_not_nil province_concern
            assert_equal result.suggestions.map(&:id), province_concern.suggestion_ids
            assert_equal "Province may be incorrect.", province_concern.message

            zip_concern = result.concerns.find { |c| :zip_inconsistent == c.code }
            assert_not_nil zip_concern
            assert_equal result.suggestions.map(&:id), zip_concern.suggestion_ids
            assert_equal "Postal code may be incorrect.", zip_concern.message
          end

          test "adds invalid zip concern without suggestions when ConcernBuilder.should_suggest? is false and /
              zip/province are mutually invalid" do
            ConcernBuilder.expects(:should_suggest?).once.returns(false)
            @address = address(province_code: "AB") # K2P 1L4 is not valid for Alberta
            result = result()
            address_comparison = address_comparison(province_code: "ON") # mismatch on province

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.concerns.size
            assert_equal [:country_code, :province_code], result.validation_scope
            zip_concern = result.concerns.first
            assert_equal :zip_invalid_for_province, zip_concern.code
            assert_empty zip_concern.suggestion_ids
          end

          test "does not add an invalid zip concern when ConcernBuilder.should_suggest? is false and given /
            zip/province are mutually consistent" do
            ConcernBuilder.expects(:should_suggest?).once.returns(false)
            @address = address
            result = result()
            address_comparison = address_comparison(province_code: "AB") # mismatch on province

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal AddressValidation::Result::SORTED_VALIDATION_SCOPES, result.validation_scope
            assert_empty result.concerns
            assert_empty result.suggestions
          end

          test "adds address_unknown concern without suggestions when ConcernBuilder.should_suggest? is false /
              candidate differs from input address by 3+ components" do
            ConcernBuilder.expects(:should_suggest?).once.returns(false)
            @address = address
            result = result()
            address_comparison = address_comparison(city: "Poletown", zip: "H0H 0H0", province_code: "NU")

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.concerns.size
            assert_equal [:country_code, :province_code, :zip, :city], result.validation_scope
            address_unknown_concern = result.concerns.first
            assert_equal :address_unknown, address_unknown_concern.code
            assert_empty address_unknown_concern.suggestion_ids
          end

          test "adds address_unknown concern without suggestions when ConcernBuilder.should_suggest? is false /
              candidate differs from input address by 3+ components, including components we are not validating" do
            ConcernBuilder.expects(:should_suggest?).once.returns(false)
            @address = address
            result = result()
            address_comparison = address_comparison(city: "Poletown", zip: "H0H 0H0", address1: "Main Ave")

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: AddressValidation::MatchingStrategies::Es,
              result: result,
            ).update_result

            assert_equal 1, result.concerns.size
            assert_equal [:country_code, :province_code, :zip, :city], result.validation_scope
            address_unknown_concern = result.concerns.first
            assert_equal :address_unknown, address_unknown_concern.code
            assert_empty address_unknown_concern.suggestion_ids
          end

          test "removes the validation scopes of unmatched fields and their contained scopes" do
            @address = address
            result = result()
            address_comparison = address_comparison(city: ["Nepean"], zip: "K2L 1P4")

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal [:country_code, :province_code], result.validation_scope
          end

          test "does not add result concerns and suggestions for street component when excluded from validation" do
            @address = build_address(
              address1: "123 Man Street", # typo
              city: "Pan Francisco", # typo
              province_code: "CA",
              country_code: "US",
              zip: "94102",
            )

            RelevantComponents.any_instance.stubs(:components_to_compare).returns([
              :city,
              :province_code,
              :zip,
              :street,
            ])
            # excludes street component
            RelevantComponents.any_instance.stubs(:components_to_validate).returns([:city, :province_code, :zip])

            result = result()
            address_comparison = address_comparison(street: "Main Street", city: ["San Francisco"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_nil result.suggestions.first.attributes[:address1]
            assert_equal "San Francisco", result.suggestions.first.attributes[:city]
          end

          test "does not add result concerns and suggestions for city component when excluded from validation" do
            @address = build_address(
              address1: "123 Man Street", # typo
              city: "Pan Francisco", # typo
              province_code: "CA",
              country_code: "US",
              zip: "94102",
            )

            RelevantComponents.any_instance.stubs(:components_to_compare).returns([
              :city,
              :province_code,
              :zip,
              :street,
            ])
            # excludes city component
            RelevantComponents.any_instance.stubs(:components_to_validate).returns([:province_code, :zip, :street])

            result = result()
            address_comparison = address_comparison(address1: "123 Main Street", city: ["San Francisco"])

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_equal 1, result.concerns.size
            assert_equal :street_inconsistent, result.concerns.first.code
            assert_nil result.suggestions.first.attributes[:city]
            assert_equal "123 Main Street", result.suggestions.first.attributes[:address1]
          end

          test "does not flag a street concern when street_sequences are not in one of the address lines" do
            address_hash = {
              address1: "123 Man Street",
              address2: "",
              city: "San Francisco",
              province_code: "CA",
              country_code: "US",
              zip: "94102",
            }

            address = build_address(**address_hash)

            datastore = AddressValidation::Es::Datastore.new(address: address)
            datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(address.city)
            datastore.street_sequences = [AtlasEngine::AddressValidation::Token::Sequence.from_string("bad parsing")]

            candidate = AddressValidation::Candidate.new(
              id: "1",
              source: address_hash.merge({ street: "Main Street", phone: nil }),
            )

            RelevantComponents.any_instance.stubs(:components_to_compare).returns([:street])
            RelevantComponents.any_instance.stubs(:components_to_validate).returns([:street])

            logged_address = address.to_h.dup.merge({ potential_streets: ["Man Street"] })
            logged_address.delete(:phone)
            logged_address.delete(:address2)

            assert_log_append(
              :info,
              "AtlasEngine::AddressValidation::Validators::FullAddress::CandidateResult",
              "[AddressValidation] Unable to identify unmatched field name",
              logged_address,
            )

            result = result()
            address_comparison = AddressValidation::Validators::FullAddress::AddressComparison.new(
              address: address,
              candidate: candidate,
              datastore: datastore,
            )

            CandidateResult.new(
              address_comparison: address_comparison,
              matching_strategy: @matching_strategy,
              result: result,
            ).update_result

            assert_empty result.concerns
          end

          def address_comparison(source = {})
            datastore = AddressValidation::Es::Datastore.new(address: @address)
            datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.city)
            datastore.street_sequences = datastore.parsings.potential_streets.map do |street|
              AtlasEngine::AddressValidation::Token::Sequence.from_string(street)
            end

            candidate_hash = @address.to_h.merge(source)
            candidate_hash[:street] = ValidationTranscriber::AddressParsings.new(
              address_input: Types::AddressValidation::AddressInput.from_hash(candidate_hash),
            ).potential_streets.first

            candidate = AddressValidation::Candidate.new(id: "A", source: candidate_hash)

            AddressValidation::Validators::FullAddress::AddressComparison.new(
              address: @address,
              candidate: candidate,
              datastore: datastore,
            )
          end

          def address(overrides = {})
            default_address = {
              phone: "613-555-1867",
              address1: "150 Elgin Street",
              address2: "Suite Home Alabamuh!",
              city: "Ottawa",
              zip: "K2P 1L4",
              province_code: "ON",
              country_code: "CA",
            }
            build_address(**default_address.merge(overrides))
          end

          def result(overrides = {})
            default_result = {
              validation_scope: AddressValidation::Result::SORTED_VALIDATION_SCOPES.dup,
            }

            AddressValidation::Result.new(**default_result.merge(overrides))
          end
        end
      end
    end
  end
end
