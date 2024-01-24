# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class ComparisonPolicyTest < ActiveSupport::TestCase
          test "#initialize raises error for unknown unmatched policy" do
            assert_raises RuntimeError do
              ComparisonPolicy.new(unmatched: :unknown)
            end
          end

          test "#initialize does not raise error for known unmatched policy" do
            assert_equal :retain, ComparisonPolicy.new(unmatched: :retain).unmatched
          end
        end
      end
    end
  end
end
