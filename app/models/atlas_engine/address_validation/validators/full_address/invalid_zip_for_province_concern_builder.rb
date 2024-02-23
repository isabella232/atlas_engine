# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForProvinceConcernBuilder
          extend T::Sig
          include ConcernFormatter
          attr_reader :address

          def initialize(address)
            @address = address
          end

          sig { params(suggestion_ids: T::Array[String]).returns(Concern) }
          def build(suggestion_ids = [])
            message = country.field(key: :zip).error(
              code: :invalid_for_province,
              options: { province: province_name },
            ).to_s

            Concern.new(
              field_names: [:zip],
              code: :zip_invalid_for_province,
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids,
              message: message,
            )
          end
        end
      end
    end
  end
end
