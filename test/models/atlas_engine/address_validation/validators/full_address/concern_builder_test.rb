# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ConcernBuilderTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::ConcernBuilder
            @address = build_address(country_code: "US")
            @suggestion_ids = []
          end

          test ".too_many_unmatched_components? is false when the # of unmatched components is below the threshold" do
            assert_not @klass.too_many_unmatched_components?(@address, [:city])
          end

          test ".too_many_unmatched_components? is false when the # of unmatched components is at the threshold" do
            assert_not @klass.too_many_unmatched_components?(@address, [:city, :province_code])
          end

          test ".too_many_unmatched_components? is true when the # of unmatched components is above the threshold" do
            assert @klass.too_many_unmatched_components?(@address, [:city, :province_code, :zip])
          end

          test ".valid_zip_for_province? true when zip prefix is valid for province" do
            address = build_address(zip: "K1A 0A6", province_code: "ON", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? false when zip prefix is invalid for province" do
            address = build_address(zip: "V1A 0A6", province_code: "ON", country_code: "CA")
            assert_not @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true when country has no postal codes" do
            address = build_address(country_code: "MO")
            assert @klass.valid_zip_for_province?(address) # Macau
          end

          test ".valid_zip_for_province? true if province is empty" do
            address = build_address(zip: "K1A 0A6", province_code: "", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true if province is non existent" do
            address = build_address(zip: "K1A 0A6", province_code: "xx", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true if province is invalid and country hides provinces" do
            address = build_address(zip: "PH8 0DB", province_code: "ENG", country_code: "GB")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".build returns a :field_inconsistent concern by default" do
            builder = @klass.new(
              unmatched_component: :field1,
              matched_components: [:field2, :field3],
              address: @address,
              suggestion_ids: @suggestion_ids,
            )

            result = builder.build

            assert_instance_of AddressValidation::Concern, result
            assert_equal :field1_inconsistent, result.code
            assert_equal @suggestion_ids, result.suggestion_ids
          end

          test ".build returns a :zip_inconsistent concern when zip is unmatched and valid for province" do
            address = build_address(country_code: "US", province_code: "ON", zip: "90411", city: "blah")

            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:city],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            result = builder.build

            assert_instance_of AddressValidation::Concern, result
            assert_equal :zip_inconsistent, result.code
            assert_equal @suggestion_ids, result.suggestion_ids
          end

          test ".build returns an :invalid_zip_for_province concern when unmatched zip prefix is invalid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "80210")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            result = builder.build

            assert_instance_of AddressValidation::Concern, result
            assert_equal :zip_invalid_for_province, result.code
            assert_equal @suggestion_ids, result.suggestion_ids
          end

          test ".build returns an :invalid_zip_for_country when unmatched zip prefix is invalid for country" do
            address = build_address(country_code: "DK", zip: "66000", province_code: nil, city: "Vejen")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            result = builder.build

            assert_instance_of AddressValidation::Concern, result
            assert_equal :zip_invalid_for_country, result.code
            assert_equal @suggestion_ids, result.suggestion_ids
          end

          test ".build returns an :unknown_province concern when province_code is unmatched and /
              city/zip are matched" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            builder = @klass.new(
              unmatched_component: :province_code,
              matched_components: [:city, :zip],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            result = builder.build

            assert_instance_of AddressValidation::Concern, result
            assert_equal :province_inconsistent, result.code
            assert_equal @suggestion_ids, result.suggestion_ids
          end

          test ".should_suggest? returns false when unmatched components size is greater than threshold" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :zip, :city]

            assert unmatched_component_keys.size > 2
            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when only one component is unmatched" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns false when province and city are unmatched and zip is invalid for province" do
            address = build_address(country_code: "US", province_code: "TX", zip: "90210")
            unmatched_component_keys = [:province_code, :zip]

            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns false when province and zip are unmatched and zip is invalid for province" do
            address = build_address(country_code: "US", province_code: "TX", zip: "90210")
            unmatched_component_keys = [:province_code, :city]

            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when province and city are unmatched and zip is valid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :city]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when province and zip are unmatched and zip is valid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :zip]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end
        end
      end
    end
  end
end
