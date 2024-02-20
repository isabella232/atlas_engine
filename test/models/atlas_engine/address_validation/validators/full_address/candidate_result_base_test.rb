# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CandidateResultBaseTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @address = build_address(
              phone: "613-555-1867",
              address1: "150 Elgin Street",
              address2: "Suite Home Alabamuh!",
              city: "Ottawa",
              zip: "K2P 1L4",
              province_code: "ON",
              country_code: "CA",
            )
          end

          class TestCandidateResultBase < CandidateResultBase; end

          test "#update_result_scope removes scopes for fields with concerns" do
            result = build_result
            result.validation_scope = [:province_code, :zip, :city, :address1, :address2]
            result.concerns << Concern.new(
              code: :invalid_zip,
              field_names: [:zip],
              message: "Enter a valid ZIP for Ottawa",
              type: "warning",
              type_level: 3,
              suggestion_ids: [],
            )

            klass = TestCandidateResultBase.new(address: @address, result: result)
            klass.send(:update_result_scope)

            assert_equal [:province_code], result.validation_scope
          end

          test "#contained_scopes_for returns scopes after the given scope" do
            result = build_result
            result.validation_scope = [:province_code, :zip, :city, :address1, :address2]

            klass = TestCandidateResultBase.new(address: @address, result: result)

            assert_equal [:province_code, :zip, :city, :address1, :address2, :phone],
              klass.send(:contained_scopes_for, :province_code)
            assert_equal [:zip, :city, :address1, :address2, :phone], klass.send(:contained_scopes_for, :zip)
            assert_equal [:city, :address1, :address2, :phone], klass.send(:contained_scopes_for, :city)
          end

          def build_result(overrides = {})
            default_result = {
              validation_scope: Result::SORTED_VALIDATION_SCOPES.dup,
            }

            Result.new(**default_result.merge(overrides))
          end
        end
      end
    end
  end
end
