# frozen_string_literal: true

module ShopifyApp
  module AdminAPI
    module WithTokenRefetch
      def with_token_refetch(session, shopify_id_token)
        retrying = false if retrying.nil?
        yield
      rescue ShopifyAPI::Errors::HttpResponseError => error
        if error.code != 401
          ShopifyApp::Logger.debug("Encountered error: #{error.code} - #{error.response.inspect}, re-raising")
        elsif retrying
          ShopifyApp::Logger.debug("Shopify API returned a 401 Unauthorized error that was not corrected " \
            "with token exchange, deleting current session and re-raising")
          ShopifyApp::SessionRepository.delete_session(session.id)
        else
          retrying = true
          ShopifyApp::Logger.debug("Shopify API returned a 401 Unauthorized error, exchanging token and " \
            "retrying with new session")
          new_session = ShopifyApp::Auth::TokenExchange.perform(shopify_id_token)
          session.copy_attributes_from(new_session)
          retry
        end
        raise
      end
    end
  end
end
