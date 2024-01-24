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
          Pl::AddressImporter::Corrections::OpenAddress::PostalCodePlaceholderCorrector,
          Pl::AddressImporter::Corrections::OpenAddress::EmptyStreetCorrector,
        ],
          @profile.ingestion.correctors(source: "open_address")
      end

      test "#address_parser returns the custom PL parser" do
        assert_equal Pl::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end
    end
  end
end
