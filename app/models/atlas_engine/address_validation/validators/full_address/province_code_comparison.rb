# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ProvinceCodeComparison < FieldComparisonBase
          extend T::Sig

          sig { override.returns(T.nilable(Token::Sequence::Comparison)) }
          def compare
            return @province_code_comparison if defined?(@province_code_comparison)

            normalized_session_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
              country_code: address.country_code,
              province_code: address.province_code,
            )
            normalized_candidate_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
              country_code: T.must(candidate.component(:country_code)).value,
              province_code: T.must(candidate.component(:province_code)).value,
            )

            @province_code_comparison = best_comparison(
              Token::Sequence.from_string(normalized_session_province_code),
              [Token::Sequence.from_string(normalized_candidate_province_code)],
              field_policy(:province_code),
            )
          end
        end
      end
    end
  end
end
