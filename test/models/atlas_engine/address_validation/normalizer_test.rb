# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class NormalizerTest < ActiveSupport::TestCase
      class TestNormalizer
        extend Normalizer
      end

      test "#normalize returns a normalized string" do
        string = "Æ Œ æ œ!@%&\"'*,.();:"
        expected_normalized_string = "ae oe ae oe"
        assert_equal expected_normalized_string, TestNormalizer.normalize(string)
      end
    end
  end
end
