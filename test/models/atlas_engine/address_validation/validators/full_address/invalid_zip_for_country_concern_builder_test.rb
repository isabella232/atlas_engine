# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForCountryConcernBuilderTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::InvalidZipForCountryConcernBuilder
            @suggestion_ids = []
          end

          test "#attributes concern - US" do
            concern = @klass.new(build_address(
              country_code: "us",
              province_code: "CA",
              zip: "11206",
            )).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:zip],
              message: "Enter a valid United States ZIP code",
              code: :zip_invalid_for_country,
              type: "error",
              type_level: 1,
              suggestion_ids: @suggestion_ids,
            }

            assert_equal expected_attributes, concern.attributes
          end

          test "#attributes concern - Canada (fr)" do
            expected_attributes = {
              field_names: [:zip],
              message: "Saisir un code postal valide pour Canada",
              code: :zip_invalid_for_country,
              type: "error",
              type_level: 1,
              suggestion_ids: @suggestion_ids,
            }

            I18n.with_locale("fr") do
              concern = @klass.new(build_address(country_code: "ca", province_code: "ON", zip: "J9A 1A1"))
                .build(@suggestion_ids)

              assert_equal expected_attributes, concern.attributes
            end
          end
        end
      end
    end
  end
end
