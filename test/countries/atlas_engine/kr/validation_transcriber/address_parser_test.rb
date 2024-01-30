# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Kr
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for KR loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("KR").validation.address_parser)
        end

        test "Parses one line Korean addresses" do
          [
            # Gu, 구, followed by street
            [:kr, "마산회원구 양덕로190 7층 뷰티제이", [{ gu: "마산회원구", street: "양덕로190", building_num: "7" }]],
            # Province (Seoul), followed by gu 구, followed by street
            [
              :kr,
              "서울 서대문구 연희동 129-1",
              [{ province: "서울", gu: "서대문구", dong: "연희동", building_num: "129", unit_num: "1" }],
            ],
            # Si, 시, followed by street
            [:kr, "김포시 양촌읍 황금로 117", [{ si: "김포시", eup: "양촌읍", street: "황금로", building_num: "117" }]],
            # Si, 시, followed by street
            [:kr, "하남시 미사강변남로 91 (망월동)", [{ si: "하남시", street: "미사강변남로", building_num: "91" }]],
            # Si, 시, followed by gu, 구, followed by street
            [
              :kr,
              "수원시 장안구 송정로46번길 18-14 (정자동)",
              [{ si: "수원시", gu: "장안구", street: "송정로46번길", building_num: "18", unit_num: "14" }],
            ],
            # Province, followed by si, 시, followed by gu, 구, followed by street
            [
              :kr,
              "경기 성남시 분당구 동판교로 122",
              [{ province: "경기", si: "성남시", gu: "분당구", street: "동판교로", building_num: "122" }],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Korean addresses" do
          [
            [
              :kr,
              "기흥구 보라동 민속마을 신창아파트",
              "201동801호",
              [
                { gu: "기흥구", dong: "보라동", street: "민속마을" },
                { building_num: "201" },
              ],
            ],
            [
              :kr,
              "경기 성남시 분당구 동판교로 122",
              " (백현동, 백현마을2단지아파트)208동 503호 ",
              [
                { province: "경기", si: "성남시", gu: "분당구", street: "동판교로", building_num: "122" },
                { dong: " (백현동, 백현마을2단지아파트)208동", street: "503호" },
                { province: "경기", si: "성남시", gu: "분당구", dong: "동판교로 122  (백현동, 백현마을2단지아파트)208동", street: "503호" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AtlasEngine::AddressValidation::Address.new(**components)

          actual = AddressParser.new(address: address).parse

          assert(
            expected.to_set.subset?(actual.to_set),
            "For input ( address1: #{address1.inspect}, address2: #{address2.inspect} )\n\n " \
              "#{expected.inspect} \n\n" \
              "Must be included in: \n\n" \
              "#{actual.inspect}",
          )
        end
      end
    end
  end
end
