# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class RelevantComponents
          extend T::Sig

          sig { returns(Candidate) }
          attr_reader :candidate

          sig { returns(AddressComparison) }
          attr_reader :address_comparison

          sig do
            params(
              address_comparison: AddressComparison,
              matching_strategy: AtlasEngine::AddressValidation::MatchingStrategies,
            ).void
          end
          def initialize(address_comparison, matching_strategy)
            @address_comparison = address_comparison
            @matching_strategy = matching_strategy
            @address = address_comparison.address
            @candidate = address_comparison.candidate
            @all_supported_components = address_comparison.relevant_components.dup
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_validate
            supported_components = @all_supported_components.dup - unsupported_components_for_country
            apply_exclusions(supported_components)
            supported_components.delete(:street) if exclude_street_validation?
            supported_components
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_compare
            @all_supported_components.dup - unsupported_components_for_country
          end

          private

          sig { params(supported_components: T::Array[Symbol]).void }
          def apply_exclusions(supported_components)
            supported_components.delete_if do |component|
              exclusions(component).any? do |exclusion|
                if exclusion.apply?(candidate, address_comparison)
                  emit_excluded_validation(component, "excluded")
                  true
                end
              end
            end
          end

          sig { returns(T::Boolean) }
          def exclude_street_validation?
            return @exclude_street_validation if defined?(@exclude_street_validation)

            @exclude_street_validation = if @matching_strategy != AddressValidation::MatchingStrategies::EsStreet
              true
            elsif address_comparison.street_comparison.sequence_comparison.blank?
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
            @country_profile ||= CountryProfile.for(@address.country_code)
          end

          sig { params(component: Symbol, reason: String).void }
          def emit_excluded_validation(component, reason)
            tags = [
              "reason:#{reason}",
              "component:#{component}",
              "country:#{@address.country_code}",
            ]
            StatsD.increment("AddressValidation.skip", sample_rate: 1.0, tags: tags)
          end

          sig { returns(T::Array[Symbol]) }
          def unsupported_components_for_country
            @unsupported_components_for_country ||= begin
              unsupported_components = []
              country = Worldwide.region(code: @address.country_code)
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
