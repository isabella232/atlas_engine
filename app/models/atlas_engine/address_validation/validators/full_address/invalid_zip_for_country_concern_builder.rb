# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForCountryConcernBuilder
          extend T::Sig
          include ConcernFormatter
          attr_reader :address

          sig { params(address: AbstractAddress).void }
          def initialize(address)
            @address = address
          end

          sig { params(suggestion_ids: T::Array[String]).returns(Concern) }
          def build(suggestion_ids = [])
            message =  country.field(key: :zip).error(
              code: :invalid_for_country,
              options: { country: country.full_name },
            ).to_s

            Concern.new(
              code: :zip_invalid_for_country,
              field_names: [:zip],
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
