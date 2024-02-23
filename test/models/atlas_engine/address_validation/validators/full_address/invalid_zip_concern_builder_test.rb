# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipConcernBuilderTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::InvalidZipConcernBuilder
            @suggestion_ids = []
          end

          test "#for returns nil when the country has no zips" do
            address = build_address(country_code: "MO", zip: "66000")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country supports zones and zip is valid for the province" do
            address = build_address(country_code: "CA", province_code: "ON", zip: "M9A 0A6")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country does not support zones and zip is valid for the country" do
            address = build_address(country_code: "DK", zip: "6600", province_code: nil, city: "Vejen")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country supports zones and hide_provinces_from_addresses and zip is valid for the country" do
            address = build_address(country_code: "GB", zip: "SW1Y 5BL", province_code: nil, city: "London")

            assert_nil @klass.for(address, [])
          end

          test "#for returns :zip_invalid_for_province when country supports zones and zip is invalid for province" do
            address = build_address(country_code: "CA", province_code: "ON", zip: "V6K 1M9  ")

            expected = Concern.new(
              code: :zip_invalid_for_province,
              field_names: [:zip],
              suggestion_ids: @suggestion_ids,
              message: "",
              type: Concern::TYPES[:error],
              type_level: 1,
            )

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.code, result.code
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns :zip_invalid_for_country concern when country does not support zones and zip is invalid for country" do
            address = build_address(country_code: "DK", zip: "66000", province_code: nil, city: "Vejen")

            expected = Concern.new(
              code: :zip_invalid_for_country,
              field_names: [:zip],
              suggestion_ids: @suggestion_ids,
              message: "",
              type: Concern::TYPES[:error],
              type_level: 1,
            )

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.code, result.code
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns :zip_invalid_for_country when country.hide_provinces_from_addresses and zip is invalid for country" do
            address = build_address(country_code: "GB", zip: "90210", province_code: nil, city: "London")
            expected = Concern.new(
              code: :zip_invalid_for_country,
              field_names: [:zip],
              suggestion_ids: @suggestion_ids,
              message: "",
              type: Concern::TYPES[:error],
              type_level: 1,
            )

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.code, result.code
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns :zip_invalid_for_country concern when address zone is unrecognized and zip is invalid for country" do
            address = build_address(country_code: "CA", province_code: "XX", zip: "Z2Z 0A7")

            expected = Concern.new(
              code: :zip_invalid_for_country,
              field_names: [:zip],
              suggestion_ids: @suggestion_ids,
              message: "",
              type: Concern::TYPES[:error],
              type_level: 1,
            )

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.code, result.code
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end
        end
      end
    end
  end
end
