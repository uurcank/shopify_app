# frozen_string_literal: true

module ShopifyApp
  module Localization
    extend ActiveSupport::Concern

    included do
      around_action :set_locale
    end

    private

    def set_locale(&action)
      locale = find_locale
      session[:locale] = locale
      I18n.with_locale(locale, &action)
    end

    def find_locale
      locale_from_params || locale_from_session || locale_from_header || I18n.default_locale
    end

    def locale_from_params
      permit_locale(params[:locale])
    end

    def locale_from_session
      permit_locale(session[:locale])
    end

    def locale_from_header
      locale = request.env.fetch("HTTP_ACCEPT_LANGUAGE", "").scan(/^[a-z]{2}(?:-[a-zA-Z]{2})?/).first
      permit_locale(locale) || permit_locale(locale&.split("-")&.first)
    end

    # Makes sure locale is in the available locales list
    def permit_locale(locale)
      # First, check if the full locale (e.g., 'es-MX') is available
      return locale if locale.presence_in(I18n.available_locales)

      # If not, fall back to the base language (e.g., 'es')
      base_locale = locale&.split('-')&.first
      base_locale.presence_in(I18n.available_locales)
    end
  end
end
