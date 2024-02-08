# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Es
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        NON_NUMERIC_STREET = "(?<street>[^[:digit:]]+)"
        BUILDING_NUM_DESIGNATOR = /(?i)(n|n°|número)/
        CATCH_ALL = /(?:,|\s|\s*.+)/

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET_NO_COMMAS},?\s+#{BUILDING_NUM}$/,
            /^#{STREET_NO_COMMAS},?\s+#{BUILDING_NUM}#{CATCH_ALL}$/,
            /^#{NON_NUMERIC_STREET},?\s+#{BUILDING_NUM}#{CATCH_ALL}$/,
            /^#{STREET_NO_COMMAS},?\s+(#{BUILDING_NUM_DESIGNATOR}\s?)#{BUILDING_NUM}/,
            /^#{STREET_NO_COMMAS},?\s+(#{BUILDING_NUM_DESIGNATOR}\s?)#{BUILDING_NUM}#{CATCH_ALL}$/,
            /^#{NON_NUMERIC_STREET},?\s+(#{BUILDING_NUM_DESIGNATOR}\s?)#{BUILDING_NUM}#{CATCH_ALL}$/,
          ]
        end
      end
    end
  end
end
