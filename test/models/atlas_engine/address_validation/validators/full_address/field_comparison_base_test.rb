# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class FieldComparisonBaseTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          class DummyFieldComparison < FieldComparisonBase
            def sequence_comparison
              nil
            end
          end

          def setup
            @candidate = Candidate.new(id: "A", source: { "zip" => "J9A 2V2" })
            @address = build_address(country_code: "CA", zip: "j9a2v2")
            @datastore = Es::Datastore.new(address: @address)
            @dummy_field_comparison = DummyFieldComparison.new(
              address: @address,
              candidate: @candidate,
              datastore: @datastore,
            )
          end

          test "#match? returns false if sequence_comparison is nil" do
            assert_not(@dummy_field_comparison.match?)
          end

          test "#match? returns value of sequence_comparison.match?" do
            comparison_mock = mock
            comparison_mock.stubs(:match?).returns(true)

            @dummy_field_comparison.stubs(:sequence_comparison).returns(comparison_mock)
            assert(@dummy_field_comparison.match?)
          end
        end
      end
    end
  end
end
