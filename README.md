# Shopify App

[![Version][gem]][gem_url] [![Build Status](https://github.com/Shopify/shopify_app/workflows/CI/badge.svg)](https://github.com/Shopify/shopify_app/actions?query=workflow%3ACI)

[gem]: https://img.shields.io/gem/v/shopify_app.svg
[gem_url]: https://rubygems.org/gems/shopify_app

This gem builds Rails applications that can be embedded in the Shopify Admin.

[Introduction](#introduction) |
[Requirements](#requirements) |
[Usage](#usage) |
[Documentation](#documentation) |
[Contributing](/CONTRIBUTING.md) |
[License](/LICENSE)


## Introduction

This gem includes a Rails engine, generators, modules, and mixins that help create Rails applications that work with Shopify APIs. The [Shopify App Rails engine](/docs/shopify_app/engine.md) provides all the code required to implement OAuth with Shopify. The [default Shopify App generator](/docs/shopify_app/generators.md#-environment-rails-generate-shopify_app) builds an app that can be embedded in the Shopify Admin and secures it with [session tokens](https://shopify.dev/concepts/apps/building-embedded-apps-using-session-tokens).

<!-- This section is linked to in `templates/shopify_app.rb.tt`. Be careful renaming this heading. -->
## Requirements

To become a Shopify app developer, you will need a [Shopify Partners](https://www.shopify.com/partners) account. Explore the [Shopify dev docs](https://shopify.dev/concepts/shopify-introduction) to learn more about [building Shopify apps](https://shopify.dev/concepts/apps).

This gem requires that you have the following credentials:

- **Shopify API key:** The API key app credential specified in your [Shopify Partners dashboard](https://partners.shopify.com/organizations).
- **Shopify API secret:** The API secret key app credential specified in your [Shopify Partners dashboard](https://partners.shopify.com/organizations).

## Usage

1. To get started, create a new Rails app:

``` sh
rails new my_shopify_app
```

2. Add the Shopify App gem to the app's Gemfile:

```sh
bundle add shopify_app
```

3. You will need to provide several environment variables to the app.
There are a variety of way of doing this, but for a development environment we recommended the [`dotenv-rails`](https://github.com/bkeepers/dotenv) gem.
Create a `.env` file in the root of your Rails app to specify the full host and Shopify API credentials:

```sh
HOST=http://localhost:3000
SHOPIFY_API_KEY=<Your Shopify API key>
SHOPIFY_API_SECRET=<Your Shopify API secret>
```

4. Run the default Shopify App generator to create an app that can be embedded in the Shopify Admin:

```sh
rails generate shopify_app
```

5. Run a migration to create the necessary tables in your database:

```sh
rails db:migrate
```

6. Run the app:

```sh
rails server
```

7. Within [Shopify Partners](https://www.shopify.com/partners), navigate to your App, then App Setup, and configure the URLs, e.g.:

  * App URL: http://localhost:3000/
  * Allowed redirection URL(s): http://localhost:3000/auth/shopify/callback

8. Install the app by visiting the server's URL (e.g. http://localhost:3000) and specifying the subdomain of the shop where you want it to be installed to.

9. After the app is installed, you're redirected to the embedded app.

This app implements [OAuth 2.0](https://shopify.dev/tutorials/authenticate-with-oauth) with Shopify to authenticate requests made to Shopify APIs. By default, this app is configured to use [session tokens](https://shopify.dev/concepts/apps/building-embedded-apps-using-session-tokens) to authenticate merchants when embedded in the Shopify Admin.

See [*Generators*](/docs/shopify_app/generators.md) for a complete list of generators available to Shopify App.

## Documentation

You can find documentation on gem usage, concepts, mixins, installation, and more in [`/docs`](/docs).

* Start with the [*Generators*](/docs/shopify_app/generators.md) document to learn more about the generators this gem offers.
* Check out the [*Changelog*](/CHANGELOG.md) for notes on the latest gem releases.
* See [*Troubleshooting*](/docs/Troubleshooting.md) for tips on common issues.
* If you are looking to upgrade your Shopify App version to a new major release, see [*Upgrading*](/docs/Upgrading.md) for important notes on breaking changes.

### Overview

[Quickstart](/docs/Quickstart.md)

[Troubleshooting](/docs/Troubleshooting.md)

[Upgrading](/docs/Upgrading.md)

[Shopify App](/docs/shopify_app)
  * [Authentication](/docs/shopify_app/authentication.md)
  * [Engine](/docs/shopify_app/engine.md)
  * [Controller Concerns](/docs/shopify_app/controller-concerns.md)
  * [Generators](/docs/shopify_app/generators.md)
  * [Sessions](/docs/shopify_app/sessions.md)
  * [Handling changes in access scopes](/docs/shopify_app/handling-access-scopes-changes.md)
  * [Testing](/docs/shopify_app/testing.md)
  * [Webhooks](/docs/shopify_app/webhooks.md)
  * [Content Security Policy](/docs/shopify_app/content-security-policy.md)
  * [Logging](/docs/shopify_app/logging.md)

### Engine

Mounting the Shopify App Rails Engine provides the following routes. These routes are configured to help install your application on shops and implement OAuth.

| Verb   | Route                    | Action             |
|   ---: | :---                     | :---               |
| `GET`  | `/login`                 | Login              |
| `POST` | `/login`                 | Login              |
| `GET`  | `/auth/shopify/callback` | OAuth redirect URI |
| `GET`  | `/logout`                | Logout             |
| `POST` | `/webhooks/:type`        | Webhook callback   |

These routes are configurable. See the more detailed [*Engine*](/docs/shopify_app/engine.md) documentation to learn how you can customize the login URL or mount the Shopify App Rails engine at nested routes.

To learn more about how this gem authenticates with Shopify, see [*Authentication*](/docs/shopify_app/authentication.md).

### New embedded app authorization strategy (Token Exchange)

> [!TIP]
> If you are building an embedded app, we **strongly** recommend using [Shopify managed installation](https://shopify.dev/docs/apps/auth/installation#shopify-managed-installation)
> with [token exchange](https://shopify.dev/docs/apps/auth/get-access-tokens/token-exchange) instead of the legacy authorization code grant flow.

We've introduced a new installation and authorization strategy for **embedded apps** that
eliminates the redirects that were previously necessary.
It replaces the existing [installation and authorization code grant flow](https://shopify.dev/docs/apps/auth/get-access-tokens/authorization-code-grant).

This is achieved by using [Shopify managed installation](https://shopify.dev/docs/apps/auth/installation#shopify-managed-installation)
to handle automatic app installations and scope updates, while utilizing
[token exchange](https://shopify.dev/docs/apps/auth/get-access-tokens/token-exchange) to retrieve an access token for
authenticated API access.

##### Enabling this new strategy in your app

1. Enable [Shopify managed installation](https://shopify.dev/docs/apps/auth/installation#shopify-managed-installation)
    by configuring your scopes [through the Shopify CLI](https://shopify.dev/docs/apps/tools/cli/configuration).
> [!NOTE]
> Ensure you don't have `use_legacy_install_flow = true` in your `shopify.app.toml` configuration file. If `use_legacy_install_flow` is true, Shopify will not manage the installation process for your app.
> You should remove the `use_legacy_install_flow` line from your `shopify.app.toml` configuration file or set it to `false`.

2. Enable the new auth strategy in your app's ShopifyApp configuration file.

```ruby
# config/initializers/shopify_app.rb
ShopifyApp.configure do |config|
  #.....
  config.embedded_app = true
  config.new_embedded_auth_strategy = true

  # If your app is configured to use online sessions, you can enable session expiry date check so a new access token
  # is fetched automatically when the session expires.
  # See expiry date check docs: https://github.com/Shopify/shopify_app/blob/main/docs/shopify_app/sessions.md#expiry-date
  config.check_session_expiry_date = true
  ...
end

```
3. Handle special callback logic. If your app has overridden the OAuth CallbackController to run special tasks post authorization,
you'll need to create and configure a custom PostAuthenticateTasks class to run these tasks after the token exchange. The original
OAuth CallbackController will not be triggered anymore. See [Post Authenticate Tasks documentation](/docs/shopify_app/authentication.md#post-authenticate-tasks) for more information.
4. Make sure your `embedded_app` layout is correct. If your app has any controller which includes `ShopifyApp::EnsureInstalled`, they will now also include the `ShopifyApp::EmbeddedApp` concern, which sets `layout 'embedded_app'` for the current controller by default. In cases where the controller originally looked for another layout file, this can cause unexpected behavior. See [`EmbeddedApp` concern's documentation](/docs/shopify_app/controller-concerns.md#embeddedapp) for more information on the effects of this concern and how to disable the layout change if needed.
5. Enjoy a smoother and faster app installation process.

### API Versioning

[Shopify's API is versioned](https://shopify.dev/concepts/about-apis/versioning). With Shopify App `v1.11.0`, the included Shopify API gem allows developers to specify and update the Shopify API version they want their app or service to use. The Shopify API gem also surfaces warnings to Rails apps about [deprecated endpoints, GraphQL fields and more](https://shopify.dev/concepts/about-apis/versioning#deprecation-practices).

See the [Shopify API gem README](https://github.com/Shopify/shopify-api-ruby/) for more information.
