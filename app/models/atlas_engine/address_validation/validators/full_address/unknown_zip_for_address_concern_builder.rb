# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownZipForAddressConcernBuilder
          extend T::Sig
          attr_reader :address

          sig { params(address: AbstractAddress).void }
          def initialize(address)
            @address = address
          end

          sig { params(suggestion_ids: T::Array[String]).returns(Concern) }
          def build(suggestion_ids = [])
            message = "Enter a valid ZIP for #{address.address1}, #{address.city}"

            Concern.new(
              code: :zip_inconsistent,
              field_names: [:zip],
              message: message,
              type: T.must(Concern::TYPES[:warning]),
              type_level: 3,
              suggestion_ids: suggestion_ids,
            )
          end
        end
      end
    end
  end
end
