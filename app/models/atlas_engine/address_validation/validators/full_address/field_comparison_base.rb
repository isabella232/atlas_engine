# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class FieldComparisonBase
          extend T::Sig
          extend T::Helpers

          abstract!

          sig { returns(Symbol) }
          attr_reader :component

          sig do
            params(
              address: AbstractAddress,
              candidate: Candidate,
              datastore: DatastoreBase,
              component: Symbol,
            ).void
          end
          def initialize(address:, candidate:, datastore:, component:)
            @address = address
            @datastore = datastore
            @candidate = candidate
            @component = component
          end

          sig { abstract.returns(T::Boolean) }
          def relevant?; end

          sig { abstract.returns(T.any(T.nilable(Token::Sequence::Comparison), T.nilable(NumberComparison))) }
          def sequence_comparison; end

          sig { returns(T::Boolean) }
          def match?
            return false if sequence_comparison.nil?

            T.must(sequence_comparison).match?
          end

          private

          sig { returns(AbstractAddress) }
          attr_reader :address

          sig { returns(DatastoreBase) }
          attr_reader :datastore

          sig { returns(Candidate) }
          attr_reader :candidate

          sig do
            params(
              sequence: Token::Sequence,
              component_sequences: T::Array[Token::Sequence],
              comparison_policy: Token::Sequence::ComparisonPolicy,
            ).returns(T.nilable(Token::Sequence::Comparison))
          end
          def best_comparison(
            sequence,
            component_sequences,
            comparison_policy = Token::Sequence::ComparisonPolicy::DEFAULT_POLICY
          )
            component_sequences.map do |component_sequence|
              Token::Sequence::Comparator.new(
                left_sequence: sequence,
                right_sequence: component_sequence,
                comparison_policy:,
              ).compare
            end.min_by.with_index do |comparison, index|
              # ruby's `min` and `sort` methods are not stable
              # so we need to prefer the leftmost comparison when two comparisons are equivalent
              [comparison, index]
            end
          end

          sig { params(field: Symbol).returns(Token::Sequence::ComparisonPolicy) }
          def field_policy(field)
            datastore.country_profile.validation.comparison_policy(field)
          end
        end
      end
    end
  end
end
