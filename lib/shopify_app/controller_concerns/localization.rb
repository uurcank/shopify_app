# frozen_string_literal: true

module ShopifyApp
  module Localization
    extend ActiveSupport::Concern

    included do
      around_action :set_locale
    end

    private

    def set_locale
      locale = params[:locale] || I18n.default_locale

      # Fallback to the 2 letter language code if the requested locale unavailable
      unless I18n.available_locales.include?(locale.to_sym)
        locale = locale.split("-").first
      end

      session[:locale] = locale

      I18n.with_locale(session[:locale]) do
        yield # Executes the actual controller action
      end
    rescue I18n::InvalidLocale
      I18n.with_locale(I18n.default_locale) do
        yield # Executes the actual controller action with default locale
      end
    end
  end
end
