# Koda Content
A lightweight sinatra app that provides a restful API for storing and retrieving json and media data.

All data is stored in mongo

## Usage

To get up and running put this in your config.ru

```ruby
run Koda::Api
```

You can also mount it on another url

```ruby
run Rack::URLMap.new("/" => MyWebsite.new, "/api" => Koda::Api.new)
```