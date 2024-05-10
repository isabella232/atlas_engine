# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnmatchedFieldConcernBuilder
          extend T::Sig
          include ConcernFormatter
          attr_reader :address, :unmatched_component, :matched_components, :unmatched_field

          COMPONENTS_TO_LABELS = {
            zip: "ZIP",
            province_code: "state",
            city: "city",
            street: "street name",
          }.freeze

          SHORTENED_COMPONENT_NAMES = {
            province_code: :province,
          }.freeze

          sig do
            params(
              unmatched_component: Symbol,
              matched_components: T::Array[Symbol],
              address: AbstractAddress,
              unmatched_field: T.nilable(Symbol),
            ).void
          end
          def initialize(unmatched_component, matched_components, address, unmatched_field = nil)
            @address = address
            @unmatched_component = unmatched_component
            @matched_components = matched_components
            @unmatched_field = unmatched_field || unmatched_component
          end

          sig do
            params(
              suggestion_ids: T::Array[String],
            ).returns(Concern)
          end
          def build(suggestion_ids = [])
            Concern.new(
              code: code,
              field_names: field_names,
              message: message,
              type: T.must(Concern::TYPES[:warning]),
              type_level: 3,
              suggestion_ids: suggestion_ids,
            )
          end

          private

          sig { returns(String) }
          def message
            country.field(key: field_name).error(code: :unknown_for_address).to_s
          end

          sig { returns(Symbol) }
          def code
            "#{unmatched_component_name}_inconsistent".to_sym
          end

          sig { returns(T::Array[Symbol]) }
          def field_names
            [field_name]
          end

          sig { returns(Symbol) }
          def unmatched_component_name
            SHORTENED_COMPONENT_NAMES[unmatched_component] || unmatched_component
          end

          sig { returns(Symbol) }
          def field_name
            SHORTENED_COMPONENT_NAMES[unmatched_field] || unmatched_field
          end
        end
      end
    end
  end
end
