# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Kr
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        PROVINCE = "(?<province>.+기|서울)"
        GU = "(?<gu>.+구)"
        SI = "(?<si>.+시)"
        DONG = "(?<dong>.+동)"
        EUP = "(?<eup>.+읍)"
        STREET = "(?<street>\\S+)"
        BUILDING_NUM = "(?<building_num>\\d+(^호)?)"
        UNIT_NUM = "(?<unit_num>\\d+(^동)?)"

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            %r{
              (#{PROVINCE}\s+)?
              (#{SI}\s+)?
              (#{GU}\s+)?
              (#{DONG}\s+)?
              (#{EUP}\s+)?
              (#{STREET}\s+)?
              (#{BUILDING_NUM}(-|\s)?)?#{UNIT_NUM}?
            }x,
          ]
        end
      end
    end
  end
end
