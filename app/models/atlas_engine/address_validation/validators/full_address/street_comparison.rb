# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class StreetComparison < FieldComparisonBase
          extend T::Sig

          sig { override.returns(T.nilable(Token::Sequence::Comparison)) }
          def sequence_comparison
            return @street_comparison if defined?(@street_comparison)

            street_sequences = datastore.fetch_street_sequences
            candidate_sequences = T.must(candidate.component(:street)).sequences

            @street_comparison = street_sequences.map do |street_sequence|
              best_comparison(
                street_sequence,
                candidate_sequences,
                field_policy(:street),
              )
            end.min
          end
        end
      end
    end
  end
end
