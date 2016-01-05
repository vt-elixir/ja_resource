# JaResource

A behaviour to reduce boilerplate in your JSON-API compliant Phoenix 
controllers with out sacrificing flexibility.

## Rational

JaResource lets you focus on the data in your APIs, instead of worrying about 
response status, rendering validation errors, and inserting changesets.

** DISCLAIMER: This is curretly pre-release software **

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ja_resource to your list of dependencies in `mix.exs`:

        def deps do
          [{:ja_resource, "~> 0.0.1"}]
        end

  2. Ensure ja_resource is started before your application:

        def application do
          [applications: [:ja_resource]]
        end
