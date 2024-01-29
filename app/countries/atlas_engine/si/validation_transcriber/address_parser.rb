# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        STREET = "(?<street>.+?)" # the .+ is non-greedy to allow for optional building number prefixes
        BUILDING_NUM = "(?<building_num>[0-9]+(\s?[[:alpha:]]*))"
        # the current OpenAddress dataset does not include unit numbers

        sig { override.returns(T::Array[AddressComponents]) }
        def parse
          # addressses sometimes follow an abbreviation with a period and no space afterward
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
            /^#{STREET}\s+#{BUILDING_NUM}$/,
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
