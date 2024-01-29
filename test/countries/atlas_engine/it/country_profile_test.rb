# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module It
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("IT")
      end

      test "validation unmatched_components_suggestion_threshold is set to 1" do
        assert_equal 1, @profile.validation.unmatched_components_suggestion_threshold
      end
    end
  end
end
