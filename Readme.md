[![Build Status](https://travis-ci.org/KodaFramework/koda-api.png)](https://travis-ci.org/KodaFramework/koda-api)
[![Code Climate](https://codeclimate.com/github/KodaFramework/koda-api.png)](https://codeclimate.com/github/KodaFramework/koda-api)


# Koda Api
A lightweight sinatra app that provides a restful API for storing and retrieving json and media data.

All json data is stored in mongo, media data can be stored wherever you like or use one of the built in storage providers.

## Setup

To get up and running put this in your config.ru

```ruby
run Koda::Api
```

You can also mount it on another url

```ruby
run Rack::URLMap.new("/" => MyWebsite.new, "/api" => Koda::Api.new)
```

## Usage

Once you have the server up and running you can now put data into it

Available verbs are get/put/delete

put is used to create or update content and you will get a 201 for create and a 200 for update.
get and delete will both return a 200 unless the content does not exist in which case you will get a 404.

### JSON

```ruby
put '/cars/ferrari.json', {"price": "300000", "in_stock", true}
```

You can then request this document directly:

```ruby
get '/cars/ferrari.json'
```

which will return:

```json
{
    "price": "300000",
    "in_stock": true
}
```

or ge a list of all cars:

```ruby
get '/cars'
```

of which we only have one at the moment:

```json
[
    { "url": "/cars/ferrari.json" }
]
```

and then of course you can delete it

```ruby
delete '/cars/ferrari.json'
```

### Media

The same operations are available for binary files, put however works slightly differently.

```ruby
put '/cars/ferrari.jpeg', media: UploadedFile.new('/path/to/file')
```

and you will now be able to get/delete that file.

### Media Storage

Storing media works differently from json. You can choose a storage provider that will handle storage in which ever way you choose.

By default the `Koda::MediaStorage::FileSystem` is used and stores media in the /media directory of your application (it will create it if it does not exist)

This will not work for hosting provider such as Heroku and a different provider must be used to store media in say Amazon s3 or Mongo GridFS
(Note that the FileSystem provider is currently the only one available, more will be built)

```ruby
class MyApi < Koda::Api
    Koda::Media.provider = Koda::MediaStorage::FileSystem
end
```