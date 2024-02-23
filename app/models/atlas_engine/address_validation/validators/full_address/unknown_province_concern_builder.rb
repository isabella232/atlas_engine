# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownProvinceConcernBuilder
          extend T::Sig
          include ConcernFormatter
          attr_reader :address

          sig { params(address: AbstractAddress).void }
          def initialize(address)
            @address = address
          end

          sig { params(suggestion_ids: T::Array[String]).returns(Concern) }
          def build(suggestion_ids = [])
            message = country.field(key: :province).error(
              code: :unknown_for_city_and_zip,
              options: { city: address.city, zip: address.zip },
            ).to_s

            Concern.new(
              code: :province_inconsistent,
              field_names: [:province],
              message: message,
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids,
            )
          end
        end
      end
    end
  end
end
