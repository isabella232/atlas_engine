# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownAddressConcernBuilder
          extend T::Sig
          include ConcernFormatter

          sig { returns(TAddress) }
          attr_reader :address

          sig { params(address: TAddress).void }
          def initialize(address)
            @address = address
          end

          sig { params(suggestion_ids: T::Array[String]).returns(Concern) }
          def build(suggestion_ids = [])
            message = country.field(key: :address).error(code: :may_not_exist)

            Concern.new(
              code: :address_unknown,
              message: message,
              type: T.must(Concern::TYPES[:warning]),
              type_level: 1,
              suggestion_ids: suggestion_ids,
              field_names: [:address1],
            )
          end
        end
      end
    end
  end
end
