# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class RelevantComponents
          extend T::Sig

          attr_reader :session, :candidate, :street_comparison

          ALL_SUPPORTED_COMPONENTS = [
            :province_code,
            :city,
            :zip,
            :street,
          ].freeze

          sig do
            params(
              session: Session,
              candidate: Candidate,
              street_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
            ).void
          end
          def initialize(session, candidate, street_comparison)
            @session = session
            @candidate = candidate
            @street_comparison = street_comparison
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_validate
            supported_components = ALL_SUPPORTED_COMPONENTS.dup - unsupported_components_for_country
            apply_exclusions(supported_components)
            supported_components.delete(:street) if exclude_street_validation?
            supported_components
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_compare
            ALL_SUPPORTED_COMPONENTS.dup - unsupported_components_for_country
          end

          private

          sig { params(supported_components: T::Array[Symbol]).void }
          def apply_exclusions(supported_components)
            supported_components.delete_if do |component|
              exclusions(component).any? do |exclusion|
                if exclusion.apply?(session, candidate)
                  emit_excluded_validation(component, "excluded")
                  true
                end
              end
            end
          end

          sig { returns(T::Boolean) }
          def exclude_street_validation?
            return @exclude_street_validation if defined?(@exclude_street_validation)

            @exclude_street_validation = if session.matching_strategy !=
                AddressValidation::MatchingStrategies::EsStreet
              true
            elsif street_comparison.blank?
              emit_excluded_validation(:street, "not_found")
              true
            else
              false
            end
          end

          sig { params(component: Symbol).returns(T::Array[T.class_of(Exclusions::ExclusionBase)]) }
          def exclusions(component)
            country_profile.validation.validation_exclusions(component: component)
          end

          sig { returns(CountryProfile) }
          def country_profile
            @country_profile ||= CountryProfile.for(session.country_code)
          end

          sig { params(component: Symbol, reason: String).void }
          def emit_excluded_validation(component, reason)
            tags = [
              "reason:#{reason}",
              "component:#{component}",
              "country:#{session.country_code}",
            ]
            StatsD.increment("AddressValidation.skip", sample_rate: 1.0, tags: tags)
          end

          sig { returns(T::Array[Symbol]) }
          def unsupported_components_for_country
            @unsupported_components_for_country ||= begin
              unsupported_components = []
              country = Worldwide.region(code: session.address.country_code)
              unsupported_components << :province_code if country.province_optional?
              unsupported_components << :province_code if country.hide_provinces_from_addresses
              unsupported_components << :city unless country.city_required?
              unsupported_components << :zip unless country.zip_required? && !country.zip_autofill_enabled
              unsupported_components.uniq
            end
          end
        end
      end
    end
  end
end
