# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Error < StandardError
      extend T::Sig

      sig { params(message: String, cause: T.nilable(Exception)).void }
      def initialize(message, cause = nil)
        super(message)
        @cause = cause
      end

      sig { returns(T.nilable(Exception)) }
      attr_reader :cause
    end
  end
end
