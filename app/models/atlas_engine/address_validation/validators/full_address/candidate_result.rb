# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CandidateResult < CandidateResultBase
          extend T::Sig
          include LogHelper

          sig do
            params(
              address_comparison: AddressComparison,
              matching_strategy: AddressValidation::MatchingStrategies,
              result: Result,
            ).void
          end
          def initialize(address_comparison:, matching_strategy:, result:)
            super(address: address_comparison.address, result: result)
            @address_comparison = address_comparison
            @candidate = address_comparison.candidate
            @matching_strategy = matching_strategy
          end

          sig { override.void }
          def update_result
            result.candidate = candidate.serialize
            return if unmatched_components_to_validate.empty?

            update_concerns_and_suggestions
            update_result_scope
          end

          sig { returns(T::Boolean) }
          def suggestable?
            ConcernBuilder.should_suggest?(address, unmatched_components.keys)
          end

          private

          sig { returns(Candidate) }
          attr_reader :candidate

          sig { returns(AddressComparison) }
          attr_reader :address_comparison

          sig { void }
          def update_concerns_and_suggestions
            if suggestable?
              add_concerns_with_suggestions
            else
              add_concerns_without_suggestions
            end
          end

          sig { void }
          def add_concerns_without_suggestions
            concern = InvalidZipConcernBuilder.for(address, [])
            result.concerns << concern if concern

            if ConcernBuilder.too_many_unmatched_components?(address, unmatched_components.keys)
              result.concerns << UnknownAddressConcernBuilder.new(address).build
            end
          end

          sig { void }
          def add_concerns_with_suggestions
            unmatched_components_to_validate.keys.each do |unmatched_component|
              field_name = unmatched_field_name(unmatched_component)
              if field_name.nil?
                log_unknown_field_name
                next
              end

              concern = ConcernBuilder.new(
                unmatched_component: unmatched_component,
                unmatched_field: field_name,
                matched_components: matched_components_to_validate.keys,
                address: address,
                suggestion_ids: [suggestion.id].compact,
              ).build
              result.concerns << concern
            end
            result.suggestions << suggestion
          end

          sig { returns(Suggestion) }
          def suggestion
            unmatched_fields = { street: unmatched_field_name(:street) }.compact

            @suggestion ||= SuggestionBuilder.from_comparisons(
              address.to_h,
              unmatched_components_to_validate,
              candidate,
              unmatched_fields,
            )
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def matched_components
            @matched_components || split_matched_and_unmatched_components.first
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def unmatched_components
            @unmatched_components || split_matched_and_unmatched_components.second
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def matched_components_to_validate
            matched_components.select do |k, _v|
              components_to_validate.include?(k)
            end
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def unmatched_components_to_validate
            unmatched_components.select do |k, _v|
              components_to_validate.include?(k)
            end
          end

          sig { returns(T::Hash[Symbol, T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)]) }
          def matched_and_unmatched_components
            components = {}
            @matched_and_unmatched_components ||= begin
              components_to_compare.each do |component|
                components[component] = address_comparison.for(component).sequence_comparison
              end
              components
            end
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_validate
            relevant_components.components_to_validate
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_compare
            relevant_components.components_to_compare
          end

          sig { returns(RelevantComponents) }
          def relevant_components
            @relevant_components ||= RelevantComponents.new(address_comparison, @matching_strategy)
          end

          sig do
            returns(T::Array[T::Hash[Symbol,
              T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)]])
          end
          def split_matched_and_unmatched_components
            return @matched_components, @unmatched_components if defined?(@matched_components) &&
              defined?(@unmatched_components)

            @matched_components, @unmatched_components = matched_and_unmatched_components.partition do |_, comparison|
              comparison&.match?
            end.map(&:to_h)
          end

          sig { params(component: Symbol).returns(T.nilable(Symbol)) }
          def unmatched_field_name(component)
            return component unless component == :street
            return if unmatched_components_to_validate[:street].nil?

            original_street = T.must(unmatched_components_to_validate[:street]).left_sequence.raw_value

            if address.address1.to_s.include?(original_street)
              :address1
            elsif address.address2.to_s.include?(original_street)
              :address2
            end
          end

          sig { void }
          def log_unknown_field_name
            potential_streets = { potential_streets: address_comparison.parsings.potential_streets }
            input_address = address.to_h.compact_blank.except(:phone)
            log_details = input_address.merge(potential_streets)
            log_info("[AddressValidation] Unable to identify unmatched field name", log_details)
          end
        end
      end
    end
  end
end
