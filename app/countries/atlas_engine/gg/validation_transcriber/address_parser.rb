# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        CITY = %r{
          (?<city>
            st\.?\s?saviour[']?[s]?|
            st\.?\s?sampson[']?[s]?|
            st\.?\s?andrew[']?[s]?|
            st\.?\s?martin[']?[s]?|
            st\.?\s?peter[']?[s]?\s?port|
            st\.?\s?peter[']?[s]?|
            st\.?\s?pierre\s?du\s?bois|
            vale|
            torteval|
            castel|
            forest
          )
        }ix

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{BUILDING_NAME},\s+#{CITY}$/,
            /^#{BUILDING_NAME},\s+#{STREET_NO_COMMAS},\s+#{CITY}$/,
            /^#{BUILDING_NAME},\s+#{STREET_NO_COMMAS}$/,
            /^#{NUMERIC_ONLY_BUILDING_NUM}?\s+#{STREET_NO_COMMAS},\s+#{CITY}$/,
            /^#{UNIT_TYPE}\s+#{UNIT_NUM_NO_HYPHEN},\s+#{BUILDING_NAME},\s+#{CITY}$/,
            /^#{CITY}$/,
            /^#{NUMERIC_ONLY_BUILDING_NUM}?\s+#{STREET_NO_COMMAS}$/,
            /^#{BUILDING_NAME}$/,
            /^#{STREET_NO_COMMAS}$/,
          ]
        end
      end
    end
  end
end
