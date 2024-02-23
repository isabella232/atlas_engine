# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipConcernBuilder
          class << self
            extend T::Sig

            sig do
              params(
                address: AbstractAddress,
                suggestion_ids: T::Array[String],
              ).returns(T.nilable(AddressValidation::Concern))
            end
            def for(address, suggestion_ids)
              country = Worldwide.region(code: address.country_code)

              province = country.zone(code: address.province_code.presence || "")
              return unless country.has_zip?

              if country_expects_zone_in_address?(country) && province.province?
                return if province.valid_zip?(address.zip)

                InvalidZipForProvinceConcernBuilder.new(address).build
              else
                return if country.valid_zip?(address.zip)

                InvalidZipForCountryConcernBuilder.new(address).build(suggestion_ids)
              end
            end

            private

            sig { params(country: Worldwide::Region).returns(T::Boolean) }
            def country_expects_zone_in_address?(country)
              country.zones&.any?(&:province?) && !country.hide_provinces_from_addresses
            end
          end
        end
      end
    end
  end
end
