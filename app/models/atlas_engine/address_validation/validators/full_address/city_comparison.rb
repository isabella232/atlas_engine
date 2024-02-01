# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CityComparison < FieldComparisonBase
          extend T::Sig

          sig { override.returns(T.nilable(Token::Sequence::Comparison)) }
          def sequence_comparison
            return @city_comparison if defined?(@city_comparison)

            @city_comparison = best_comparison(
              datastore.fetch_city_sequence,
              T.must(candidate.component(:city)).sequences,
              field_policy(:city),
            )
          end
        end
      end
    end
  end
end
