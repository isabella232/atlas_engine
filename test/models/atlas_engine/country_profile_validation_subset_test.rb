# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileValidationSubsetTest < ActiveSupport::TestCase
    test "index_locales returns the correct index locales if defined" do
      profile_attributes = {
        "id" => "CH",
        "validation" => {
          "index_locales" => ["de", "fr", "it"],
        },
      }
      assert_equal ["de", "fr", "it"], CountryProfile.new(profile_attributes).validation.index_locales
    end

    test "index_locales returns empty array if not defined" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {},
      }
      assert_empty CountryProfile.new(profile_attributes).validation.index_locales
    end

    test "multi_locale? returns true if country is multi-locale" do
      profile_attributes = {
        "id" => "CH",
        "validation" => {
          "index_locales" => ["de", "fr", "it"],
        },
      }
      assert CountryProfile.new(profile_attributes).validation.multi_locale?
    end

    test "multi_locale? returns false if country has no configured index_locales" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {},
      }
      assert_not CountryProfile.new(profile_attributes).validation.multi_locale?
    end

    test "multi_locale? returns false if country has only one locale" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {
          "index_locales" => ["de"],
        },
      }
      assert_not CountryProfile.new(profile_attributes).validation.multi_locale?
    end

    test "comparison_policy returns field's ComparisonPolicy when defined" do
      profile_attributes = {
        "id" => "PL",
        "validation" => {
          "comparison_policies" => {
            "street" => {
              "unmatched" => "ignore_right_unmatched",
            },
          },
        },
      }

      validation_subset = CountryProfile.new(profile_attributes).validation

      assert_equal :ignore_right_unmatched, validation_subset.comparison_policy(:street).unmatched
    end

    test "comparison_policy returns default comparison policy as fallback" do
      profile_attributes = {
        "id" => "PL",
      }

      validation_subset = CountryProfile.new(profile_attributes).validation

      assert_equal AddressValidation::Token::Sequence::ComparisonPolicy::DEFAULT_POLICY,
        validation_subset.comparison_policy(:street)
    end

    test "address_comparison raises error if field is not supported" do
      validation_subset = CountryProfile.for(CountryProfile::DEFAULT_PROFILE).validation
      assert_raises(ArgumentError) { validation_subset.address_comparison(field: :unsupported_field) }
    end

    test "address_comparison returns the correct address comparison class for each field" do
      validation_subset = CountryProfile.for(CountryProfile::DEFAULT_PROFILE).validation

      assert_equal AddressValidation::Validators::FullAddress::StreetComparison,
        validation_subset.address_comparison(field: :street)
      assert_equal AddressValidation::Validators::FullAddress::CityComparison,
        validation_subset.address_comparison(field: :city)
      assert_equal AddressValidation::Validators::FullAddress::ZipComparison,
        validation_subset.address_comparison(field: :zip)
      assert_equal AddressValidation::Validators::FullAddress::ProvinceCodeComparison,
        validation_subset.address_comparison(field: :province_code)
      assert_equal AddressValidation::Validators::FullAddress::BuildingComparison,
        validation_subset.address_comparison(field: :building)
    end

    test "zip_prefix_length returns the defined prefix length" do
      profile_attributes = {
        "validation" => {
          "zip_prefix_length" => 3,
        },
      }

      validation_subset = CountryProfile.new(profile_attributes).validation

      assert_equal 3, validation_subset.zip_prefix_length
    end

    test "zip_prefix_length returns 0 if undefined" do
      validation_subset = CountryProfile.for(CountryProfile::DEFAULT_PROFILE).validation

      assert_equal 0, validation_subset.zip_prefix_length
    end
  end
end
