# typed: strict
# frozen_string_literal: true

T.bind(self, Rake::DSL)

namespace :atlas_engine do
  namespace :graphql do
    desc "Dump the GraphQL Schema"
    task schema_dump: :environment do
      AtlasEngine::Schema.dump
    end
  end
end
