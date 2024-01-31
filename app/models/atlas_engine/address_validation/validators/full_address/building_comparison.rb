# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class BuildingComparison < FieldComparisonBase
          extend T::Sig

          sig { override.returns(T.nilable(NumberComparison)) }
          def compare
            @building_comparison ||= NumberComparison.new(
              numbers: datastore.parsings.potential_building_numbers,
              candidate_ranges: building_ranges_from_candidate(candidate),
            )
          end

          private

          sig { params(candidate: Candidate).returns(T::Array[AddressNumberRange]) }
          def building_ranges_from_candidate(candidate)
            building_and_unit_ranges = candidate.component(:building_and_unit_ranges)&.value
            return [] if building_and_unit_ranges.blank?

            building_ranges = JSON.parse(building_and_unit_ranges).keys
            building_ranges.map { |building_range| AddressNumberRange.new(range_string: building_range) }
          end
        end
      end
    end
  end
end
