# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class DefaultQueryBuilderTest < ActiveSupport::TestCase
        include AddressValidation::AddressValidationTestHelper

        setup do
          @us_profile = CountryProfile.new("id" => "US")
          @mx_profile = CountryProfile.new("id" => "MX")
        end

        test "#full_address_query returns a query with the correct fields for US" do
          parsings = parsings_for(us_address)
          query_builder = DefaultQueryBuilder.new(us_address, parsings, @us_profile)

          assert_equal expected_address_query("us"), query_builder.full_address_query
        end

        test "#full_address_query returns a query with the correct fields for a country using the defaults" do
          parsings = parsings_for(mx_address)
          query_builder = DefaultQueryBuilder.new(mx_address, parsings, @mx_profile)

          assert_equal expected_address_query("mx"), query_builder.full_address_query
        end

        test "#full_address_query returns a query without a building number clause where there is no building number" do
          parsings = parsings_for(missing_number_address)
          query_builder = DefaultQueryBuilder.new(missing_number_address, parsings, @us_profile)

          assert_equal expected_address_query("us_missing"), query_builder.full_address_query
        end

        test "#full_address_query returns a query with minimum_should_match of at least 2" do
          parsings = parsings_for(us_address)
          query_builder = DefaultQueryBuilder.new(us_address, parsings, @us_profile)
          query_builder.stubs(:city_clause).returns(nil)
          query_builder.stubs(:zip_clause).returns(nil)
          query_builder.stubs(:province_clause).returns(nil)

          assert_equal expected_address_query("with_under_4_clauses"), query_builder.full_address_query
        end

        test "#full_address_query returns a valid query for an input with address1 and address2" do
          parsings = parsings_for(us_a2_address)
          query_builder = DefaultQueryBuilder.new(us_a2_address, parsings, @us_profile)

          assert_equal expected_address_query("us_a2"), query_builder.full_address_query
        end

        test "#full_address_query returns valid query when there is fractional building number in 1 address line" do
          parsings = parsings_for(us_a1_a2_fractional_building_num_address)
          query_builder = DefaultQueryBuilder.new(us_a1_a2_fractional_building_num_address, parsings, @us_profile)

          assert_equal(
            expected_address_query("with_fractional_building_number"),
            query_builder.full_address_query,
          )
        end

        test "#full_address_query does not return a building_num_clause if the building number cannot be represented as an integer" do
          parsings = parsings_for(us_a1_fractional_building_num_address) # building number is 1/2 123

          query_builder = DefaultQueryBuilder.new(us_a1_fractional_building_num_address, parsings, @us_profile)

          assert_equal expected_address_query("without_building_number"), query_builder.full_address_query
        end

        test "#full_address_query adds two street clauses when the street name contains several words" do
          parsings = parsings_for(us_compound_street_name_address)

          query_builder = DefaultQueryBuilder.new(us_compound_street_name_address, parsings, @us_profile)
          assert_equal expected_address_query("us_compound_street_name"), query_builder.full_address_query
        end

        test "#full_address_query does not return a province clause if validation.has_provinces is false " do
          parsings = parsings_for(us_address)
          profile = CountryProfile.new(
            "id" => "US",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => false,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          )

          query_builder = DefaultQueryBuilder.new(us_address, parsings, profile)
          assert_equal expected_address_query("without_province_code"), query_builder.full_address_query
        end

        test "#full_address_query does not return a province clause if validation.has_provinces is nil " do
          parsings = parsings_for(us_address)
          profile = CountryProfile.new(
            "id" => "US",
            "validation" => {
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
              "has_provinces" => nil,
            },
          )

          query_builder = DefaultQueryBuilder.new(us_address, parsings, profile)
          assert_equal expected_address_query("without_province_code"), query_builder.full_address_query
        end

        test "#full_address_query does not return a province clause if validation.has_provinces is true /
          but address does not have a province_code" do
          parsings = parsings_for(us_address_wo_province)
          profile = CountryProfile.new(
            "id" => "XX",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => true,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          )

          query_builder = DefaultQueryBuilder.new(us_address_wo_province, parsings, profile)
          assert_equal expected_address_query("without_province_code"), query_builder.full_address_query
        end

        test "#full_address_query returns nested city_aliases clause if city_alias is not present" do
          parsings = parsings_for(us_address)
          profile = CountryProfile.new(
            "id" => "XX",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => true,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          )

          query_builder = DefaultQueryBuilder.new(us_address, parsings, profile)
          assert_equal expected_address_query("nested_city_aliases_one_city_field"), query_builder.full_address_query
        end

        test "#full_address_query returns city match clause if city_alias is false" do
          parsings = parsings_for(us_address)
          profile = CountryProfile.new(
            "id" => "XX",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => true,
              "city_alias" => false,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          )

          query_builder = DefaultQueryBuilder.new(us_address, parsings, profile)
          assert_equal expected_address_query("city_match"), query_builder.full_address_query
        end

        private

        def us_address
          build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_address_wo_province
          build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: nil,
            country_code: "US",
            zip: "94102",
          )
        end

        def us_a2_address
          build_address(
            address1: "123",
            address2: "Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_a1_fractional_building_num_address
          build_address(
            address1: "123 1/2 Main Street",
            address2: nil,
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_a1_a2_fractional_building_num_address
          build_address(
            address1: "123 1/2",
            address2: "Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_compound_street_name_address
          build_address(
            address1: "18108 S Park View Dr",
            city: "Houston",
            province_code: "TX",
            country_code: "US",
            zip: "77084",
          )
        end

        def missing_number_address
          build_address(
            address1: "Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def mx_address
          build_address(
            address1: "Avenida Justo Sierra Méndez 491",
            city: "Campeche",
            province_code: "CAMP",
            country_code: "MX",
            zip: "24040",
          )
        end
      end
    end
  end
end
