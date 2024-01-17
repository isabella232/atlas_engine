# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CountryImportsController < ApplicationController
    extend T::Sig

    before_action :set_page, only: [:index]
    before_action :set_country_import, only: [:interrupt, :show]

    include LogHelper
    layout "application"

    sig { void }
    def initialize
      super
      @page = T.let(0, Integer)
      @country_import = T.let(T.unsafe(nil), T.nilable(CountryImport), checked: false)
      @country_imports = T.let(T.unsafe(nil), ActiveRecord::Relation, checked: false)
      @events = T.let(T.unsafe(nil), ActiveRecord::Relation, checked: false)
    end

    # GET /country_imports
    sig { void }
    def index
      @country_imports = CountryImport.order(id: :desc)
        .offset(CountryImport::PAGE_SIZE * @page)
        .limit(CountryImport::PAGE_SIZE)
    end

    sig { void }
    def show
      @events = Event.where(country_import: @country_import).order(id: :desc).limit(1000)
    end

    # GET /country_imports/1/interrupt
    sig { void }
    def interrupt
      T.must(@country_import).interrupt!

      log_info("Country import manually interrupted", { country_import_id: T.must(@country_import).id })
      redirect_back_or_to(
        country_imports_url,
        notice: "Country import manually interrupted. Wait a few minutes for ongoing jobs to stop.",
      )
    rescue => e
      log_error(
        "Country import manual interruption failed with #{e.class} - #{e.message}; stack trace #{e.backtrace.inspect}",
        { country_import_id: T.must(@country_import).id },
      )
      redirect_back_or_to(
        country_imports_url,
        alert: "Interruption of country import failed with #{e.class}, #{e.message}",
      )
    end

    private

    sig { returns(T.nilable(CountryImport)) }
    def set_country_import
      @country_import = begin
        CountryImport.find(params[:id])
      rescue
        nil
      end
    end

    sig { returns(Integer) }
    def set_page
      @page = params.fetch(:page, 0).to_i
    end
  end
end
