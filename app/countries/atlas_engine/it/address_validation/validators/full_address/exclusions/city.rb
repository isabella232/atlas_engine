# typed: true
# frozen_string_literal: true

module AtlasEngine
  module It
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class City <
              AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
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
                  true
                end
              end
            end
          end
        end
      end
    end
  end
end
