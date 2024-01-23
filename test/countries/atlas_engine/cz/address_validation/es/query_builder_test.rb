# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Cz
    module AddressValidation
      module Es
        class QueryBuilderTest < ActiveSupport::TestCase
          include AtlasEngine::AddressValidation::AddressValidationTestHelper

          test "#full_address_query returns a query with the correct fields when there is no street" do
            query_builder = QueryBuilder.new(build_address(
              address1: "250",
              city: "Drnovice",
              country_code: "CZ",
              zip: "683 04",
            ))
            assert_equal expected_address_query("cz_no_street"), query_builder.full_address_query
          end

          test "#full_address_query returns a query with the correct fields when there is a street" do
            query_builder = QueryBuilder.new(build_address(
              address1: "U Lužického semináře 10",
              city: "Praha",
              country_code: "CZ",
              zip: "118 00",
            ))
            assert_equal expected_address_query("cz_with_street"), query_builder.full_address_query
          end
        end
      end
    end
  end
end
