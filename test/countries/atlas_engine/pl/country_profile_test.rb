# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("PL")
      end

      test "#correctors value is correct for source open-address" do
        assert_equal [
          Pl::AddressImporter::Corrections::OpenAddress::CityCorrector,
          Pl::AddressImporter::Corrections::OpenAddress::EmptyStreetCorrector,
        ],
          @profile.ingestion.correctors(source: "open_address")
      end

      test "#validation_exclusions value is correct for city component" do
        assert_equal [
          Pl::AddressValidation::Exclusions::RuralAddress,
        ],
          @profile.validation.validation_exclusions(component: :city)
      end

      test "#validation_exclusions value is correct for zip component" do
        assert_equal [
          Pl::AddressValidation::Exclusions::PlaceholderPostalCode,
        ],
          @profile.validation.validation_exclusions(component: :zip)
      end

      test "#address_parser returns the custom PL parser" do
        assert_equal Pl::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end

      test "#comparison_policy value is correct for street component" do
        street_policy = @profile.validation.comparison_policy(:street)

        assert_equal :ignore_largest_unmatched_side, street_policy.unmatched
      end
    end
  end
end
