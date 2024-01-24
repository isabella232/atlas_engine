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
  end
end
