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
            saint[-|\s]sauveur|
            saint\s?sauveux|
            st\.?\s?sampson[']?[s]?|
            saint\s?samsaon|
            st\.?\s?andrew[']?[s]?|
            saint\s?andri|
            saint[-|\s]andr[é|e][-|\s]de[-|\s]la[-|\s]pommeraye|
            st\.?\s?martin[']?[s]?|
            st\.?\s?peter[']?[s]?\s?port|
            saint[-|\s]pierre\s?port|
            st\.?\s?peter[']?[s]?|
            st\.?\s?pierre\s?du\s?bois|
            st\.?\s?pierre|
            vale|
            l[é|e]\s?vale|
            le\s?valle|
            torteval|
            tort[é|e]vas|
            castel|
            l[é|e]\s?cast[é|e]|
            sainte[-|\s]marie[-|\s]du[-|\s]c[â|a]tel|
            forest|
            le\s?f[ô|o]ret|
            la\s?fouar[ê|e]t
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
