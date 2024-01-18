# frozen_string_literal: true

require_relative "lib/atlas_engine/version"

Gem::Specification.new do |spec|
  spec.name        = "atlas_engine"
  spec.version     = AtlasEngine::VERSION
  spec.author      = "Shopify"
  spec.email       = "developers@shopify.com"
  spec.homepage    = "https://github.com/Shopify/atlas_engine"
  spec.summary     = "Address Validation API"
  spec.description = "The Atlas Engine is a rails engine that provides a GraphQL API for address validation."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shopify/atlas_engine"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/atlas_engine/blob/main/CHANGELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "LICENSE.md", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.2.1"

  spec.add_dependency("annex_29")
  spec.add_dependency("elasticsearch-model")
  spec.add_dependency("elasticsearch-rails")
  spec.add_dependency("elastic-transport")
  spec.add_dependency("frozen_record")
  spec.add_dependency("graphiql-rails")
  spec.add_dependency("graphql")
  spec.add_dependency("htmlentities")
  spec.add_dependency("maintenance_tasks")
  spec.add_dependency("rails", ">= 7.0.7.2")
  spec.add_dependency("rubyzip")
  spec.add_dependency("sorbet-runtime")
  spec.add_dependency("state_machines-activerecord")
  spec.add_dependency("statsd-instrument")
  spec.add_dependency("worldwide")
end
