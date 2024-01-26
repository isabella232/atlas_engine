# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module AddressValidation
      module Exclusions
        class PlaceholderPostalCode < AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
          extend T::Sig

          class << self
            sig do
              override.params(
                session: AtlasEngine::AddressValidation::Session,
                candidate: AtlasEngine::AddressValidation::Candidate,
                address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
              ).returns(T::Boolean)
            end
            def apply?(session, candidate, address_comparison)
              placeholder_postal_code?(candidate)
            end

            private

            sig { params(candidate: AtlasEngine::AddressValidation::Candidate).returns(T::Boolean) }
            def placeholder_postal_code?(candidate)
              zip_values = T.must(candidate.component(:zip)&.values)
              zip_values.all?("00-000")
            end
          end
        end
      end
    end
  end
end
