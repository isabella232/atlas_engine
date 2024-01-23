# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Cz
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{BUILDING_NUM}$/,
            /^#{STREET_NO_COMMAS}\s+#{BUILDING_NUM}?$/,
          ]
        end

        def ridiculous?(captures, address)
          return false if captures[:street].blank?

          address.city == captures[:street]
        end
      end
    end
  end
end
