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
                  return true if address_comparison.street_comparison.nil? ||
                    address_comparison.building_comparison.nil? ||
                    address_comparison.building_comparison.candidate_ranges.empty?

                  !T.must(address_comparison.street_comparison).match? ||
                    !T.must(address_comparison.building_comparison).match?
                end
              end
            end
          end
        end
      end
    end
  end
end
