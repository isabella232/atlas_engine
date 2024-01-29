# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Pt
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class ZipTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              def setup
                @address = build_address(
                  address1: "Avenida Marginal 10",
                  country_code: "PT",
                )
                @datastore = AtlasEngine::AddressValidation::Es::Datastore.new(address: @address)
                @datastore.street_sequences = [
                  AtlasEngine::AddressValidation::Token::Sequence.from_string("Avenida Marginal"),
                ]
              end

              test "#apply? returns true if street does not match" do
                @candidate = candidate({
                  address1: "Rua Marginal",
                  building_and_unit_ranges: "{\"(0..99)/1\": {}}",
                })
                assert Zip.apply?(session(@address), @candidate, address_comparison)
              end

              test "#apply? returns true if building number does not match" do
                @candidate = candidate({
                  address1: "Avenida Marginal",
                  building_and_unit_ranges: "{\"(100..299)/1\": {}}",
                })
                assert Zip.apply?(session(@address), @candidate, address_comparison)
              end

              test "#apply? returns false only if building and street comparison match exactly" do
                @candidate = candidate({
                  address1: "Avenida Marginal",
                  building_and_unit_ranges: "{\"(0..99)/1\": {}}",
                })
                assert_not Zip.apply?(session(@address), @candidate, address_comparison)
              end

              private

              def address_comparison
                AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison.new(
                  address: @address,
                  candidate: @candidate,
                  datastore: @datastore,
                )
              end
            end
          end
        end
      end
    end
  end
end
