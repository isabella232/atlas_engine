# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class City <
              AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
              extend T::Sig
              class << self
                sig do
                  override.params(
                    candidate: AtlasEngine::AddressValidation::Candidate,
                    address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
                  )
                    .returns(T::Boolean)
                end
                def apply?(candidate, address_comparison)
                  # If the candidate city is already present in the parsings
                  address_comparison.parsings.parsings.pluck(:city)&.include?(candidate.component(:city)&.value&.first)
                end
              end
            end
          end
        end
      end
    end
  end
end
