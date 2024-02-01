# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pt
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class Zip < AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
              class << self
                sig do
                  override.params(
                    session: AtlasEngine::AddressValidation::Session,
                    candidate: AtlasEngine::AddressValidation::Candidate,
                    address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
                  )
                    .returns(T::Boolean)
                end
                def apply?(session, candidate, address_comparison)
                  street_comparison_result = address_comparison.street_comparison.sequence_comparison
                  building_comparison_result = address_comparison.building_comparison.sequence_comparison

                  return true if street_comparison_result.nil? ||
                    building_comparison_result.nil? ||
                    T.must(building_comparison_result).candidate_ranges.empty?

                  !T.must(street_comparison_result).match? ||
                    !T.must(building_comparison_result).match?
                end
              end
            end
          end
        end
      end
    end
  end
end
