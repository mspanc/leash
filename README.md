# leash-provider

[![Build Status](https://travis-ci.org/mspanc/leash-provider.svg?branch=master)](https://travis-ci.org/mspanc/leash-provider)

High-performance Ruby on Rails OAuth2 provider for a closed set of trusted apps with multiple roles support.

## Use cases

Leash is built to support the following scenario:

* You build a system that consists of multiple apps.
* List of the apps does not change too often and apps are not created during system runtime.
* You want to have a central authentication system for these apps but authorization can vary from app to app.
* You have a few fundamentally different user classes (user, admin etc.).
* These apps are trusted, in other words: if app talks to auth server with valid credentials, you don't ask user whether he/she allows to enable data flow.

Potential use cases are:

* Intranet.
* Larger websites that are decoupled into several smaller apps.

## Fundamental ideas

* As the app list is fixed, let's store their credentials in ENV. Fast, easy to maintain and compatible with 12factor.
* As tokens are not very persistent, let's use redis for storing them.
* As such app can be a subject of high load, let's use redis as a backend.
* Do not reinvent the wheel, let's use devise for authentication.

## Supported OAuth 2 flows

* Authorization Code (for apps running on a web server)
* Implicit (for browser-based or mobile apps)

## Unsupported features

At the moment, Leash does not support:

* Any other flows than mentioned above.
* Scopes.
* Token refreshing and invalidation.

## Compatible ruby version

* Leash is tested with ruby 2.2.1.

## Status

Work in progress. Early stage of development.

## License

MIT

## Author

Marcin Lewandowski