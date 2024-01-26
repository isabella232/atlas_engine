# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        STREET = "(?<street>.+?)" # the .+ is non-greedy to allow for optional building number prefixes
        BUILDING_NUM_PREFIX = "(?:nr.?\s+)"
        BUILDING_NUM = "(?<building_num>[0-9]+[[:alpha:]]*)"
        UNIT_NUM_PREFIX = "(?:\s*[/-]|\s+m.?)"
        UNIT_NUM = "(?<unit_num>[[:alpha:]0-9]+)"

        sig { override.returns(T::Array[AddressComponents]) }
        def parse
          # polish addressses sometimes follow an abbreviation with a period and no space afterward
          super.each do |components|
            components[:street]&.gsub!(
              /\A(?<prefix>.+?)(?<dot>\.)(?<non_space>\S)/i,
              "\\k<prefix> \\k<non_space>",
            )
          end
        end

        private

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET}\s+#{BUILDING_NUM_PREFIX}?#{BUILDING_NUM}(#{UNIT_NUM_PREFIX}\s*#{UNIT_NUM})?$/,
            /^#{STREET}$/,
          ]
        end

        sig do
          override.params(
            captures: T::Hash[Symbol, T.nilable(String)],
            address: AtlasEngine::AddressValidation::AbstractAddress,
          ).returns(T::Boolean)
        end
        def ridiculous?(captures, address)
          street = captures[:street]&.downcase

          if street.present?
            true unless address.address1&.downcase&.include?(street) ||
              address.address2&.downcase&.include?(street)
          end

          false
        end
      end
    end
  end
end
