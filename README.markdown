## What is the Koda Framework?

The Koda Framework allows you to create websites, iphone apps, android apps, single page js apps, flash apps or silverlight apps and manages your data with a very simple and configurable admin section

Twitter: @kodaframework
http://www.kodaframework.org/

## Features

*	Create and manage content in your own preferred structure. You can be as conservative or creative as you wish.
*   Consume the content in one of our pre-built starter-kits or use the REST api to display your content on mobiles, single page js apps, flash, silverlight etc.
*	Platform independent
*	Incredibly fast
*	Almost no learning curve
*	Supports [Heroku](http://www.heroku.com/) FREE 500mb MongoDb instance and hosting that scales
*	Always free! Open source MIT Licence

## Screenshot

## Explorer
![Content Editing](https://raw.github.com/KodaFramework/Gem/master/screenshots/adding-content.png)

---------------
# Getting started with a starter-kit
---------------

* Clone any starter kit
* Sign up at [Heroku](http://www.heroku.com/)
* Install the [heroku toolbelt](https://toolbelt.heroku.com/)
* From within the folder where you cloned the repo
    -   `heroku apps:create myapp`
    -   `heroku config:add ENABLE_CACHE=true`
    -   `heroku config:add ENVIRONMENT=production`
    -   `heroku addons:add mongolab:starter`
    -   `heroku addons:add memcache:5mb`
    -   `git push heroku master`
* Restore the starter kit database
    -   Login to your account on the [Heroku](http://www.heroku.com/) website, click on your app.
    -   Select the Mongolab-starter add-on
    -   Add a new user in the users tab and remember the username and password you created.
    -   At the top find your Mongo URI and note down the hostname, port and database
        This will be in the format (`mongodb://<dbuser>:<dbpassword>@<hostname>.mongolab.com:<port>/<database>`)
    -   From within your local folder type `heroku run console` to enter the console
    -   Perform the restore `mongorestore -h <hostname>.mongolab.com:<port> -d <database> -u <the_username_you_created> -p <the_password_you_created> data/koda`

-------------------
# Getting started with modifying or building a starter-kit
-------------------

Follow the guide here to install mongodb on your preferred platform
http://www.mongodb.org/display/DOCS/Quickstart

If you are on windows you would need to install ruby [here](http://rubyinstaller.org/)
Also install the Ruby DevKit [here](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit)

If you are on Mac OSX, you won't need to install anything
If you are on Linux, you probably don't need any help

Once you have this installed, simply...

*   Clone any starter kit
*	`gem install koda`
*   `ruby data.rb restore data/koda`
*	`shotgun -p 3000`

* 	Use your favourite editor to start developing
*	Go to `http://localhost:3000` to see your instance
*	Go to `http://localhost:3000/explorer` to register and start editing content
*	Go to `http://localhost:3000/console` after registration to browse your data

## Creating Layouts and Templates

### Layouts

> /templates/layout.rb
```html
<html>
  <body>
   <%= yield %>
  </body>
</html>
```

### Templates

Templates will automatically be rendered inside the layout

> /templates/mytemplate.rb
```html
<h3>Hello World!</h3>
```

produces...

```html
<html>
  <body>
   	<h3>Hello World!</h3>
  </body>
</html>
```

### Partials

> /templates/partials/mypartial.rb
```html
<p>my partial</p>
```

> /templates/mytemplate.rb
```html
<h3>Hello World!</h3>
<% render_partial 'partials/mypartial' %>
```

produces...

```html
<html>
  <body>
   	<h3>Hello World!</h3>
	<p>my partial</p>
  </body>
</html>
```

### Using Content inside Templates

```html
<% model.blogposts.all.each do |blogpost|%>
	<% safe('No Content has been added yet'){%>
    <h2><%=blogpost.title%></h2>
    <div>
      <%=blogpost.teaser%>
    </div>
	<%}%>
<% end%>
```

produces...

```html
   <h2>My first blogpost</h2>
   <div>
      My blogpost content
   </div>
   <h2>My second blogpost</h2>
   <div>
      My blogpost content
   </div>
   <h2>My third blogpost</h2>
   <div>
      My blogpost content
   </div>
```

## Available content filters from within a template

### Where
`model.[collection].where {|item| item.someProp == 'something' && item.alias != nil } ` returns all items that match
### Single
`model.[collection].single {|item| item.someProp == 'something' } ` returns the first item that matches
### All
`model.[collection].all ` returns all items
### By Ref
`model.[collection].by_ref 'my_ref'` returns a reference document by referenceid

### Routes

A starter-kit will have the routes defined in the config.ru file.
You can modify these, but be careful as it might break the pretty urls and paths

this is a very simple example of a route...

```ruby
get '/blog/:author/:post/:?' do
  @author = params[:author]
  @post = params[:post]
  @title = "Welcome to the BlogStarterKit"
  show :mytemplate
end
```

variables prefixed with the '@' sign will be available to your templates.

and do...

```html
<% model.blogposts.where{|post| post.author.include? @author && post.alias == @post }.each do |blogpost|%>
	<% safe('No Content has been added yet'){%>
    <h2><%=blogpost.title%></h2>
    <div>
      <%=blogpost.teaser%>
    </div>
	<%}%>
<% end%>
```

### Creating Koda Types

To Create Koda types place a new json file in the `/public/koda/koda-types` folder

Register your type in the `/public/koda/koda-types/type_registration.json` file and you can now use it in the Koda Explorer!
A new type will appear under the "User Created" section on the right.


```json
{
	"title"  : "Generic Text Editor",
	"fields" : [
		{
			"id" : "_koda_type",
			"defaultValue" : "/koda/koda-types/koda-generictext.json"
		},
		{
			"id" : "_koda_editor",
			"defaultValue" : "/koda/koda-editors/generic-editor.html"
		},
		{
			"id" : "_koda_indexes",
			"defaultValue" : "name,tags"
		},
		{
			"id" : "datecreated",
			"defaultValue" : "<%=timestamp%>"
		},
		{
			"id" : "name",
			"title" : "Name",
			"description" : "The name of the content",
			"control" : "input-text",
			"defaultValue" : "",
			"properties" : "required"
		},
		{
			"id" : "alias",
			"title" : "Alias",
			"description" : "This will be generated from the title",
			"control" : "input-readonly",
			"defaultValue" : ""
		},
		{
			"id" : "content",
			"title" : "Content",
			"description" : "The contents",
			"control" : "richtext",
			"defaultValue" : ""
		},
		{
			"id" : "tags",
			"title" : "Tags",
			"description" : "Comma separated",
			"control" : "input-text",
			"defaultValue" : ""
		}
	]
```

### Default value Accessors

You can reference any other property in a default value

`"defaultValue" : "<%=property_name%>"`

Or use a timestamp

`"defaultValue" : "<%=timestamp%>"`

[KodaTypes supports most HTML5 input types and validation](http://www.the-art-of-web.com/html/html5-form-validation/)

## Data Types

### Single field data types

* input-hidden
* input-color
* input-date
* input-text
* input-password
* input-email
* input-url
* input-number
* input-range
* input-readonly
* imageupload
* mediaupload
* textarea
* richtext
* truefalse

#### Usage

```json
{
	"id" : "name",
	"title" : "Title",
	"description" : "Title of page",
	"control" : "input-text",
	"properties" : "required  placeholder='type a page title'",
	"defaultValue" : ""
}
```

Loading from AJAX

```json
{
	"id" : "name",
	"title" : "Title",
	"description" : "Title of page",
	"control" : "input-text",
	"properties" : "required  placeholder='type a page title'",
	"defaultValue" : "",
	"ajax" : {
		"url" : "/content/pages/pageone",
		"displayfield" : "title"
	}
}
```

### Collections

* collection
* collection-multi

#### Usage

```json
{
	"id" : "homepage",
	"title" : "Select homepage",
	"description" : "Select the homepage",
	"control" : "collection",
	"defaultValue" : "",
	"values" : "value1,value2,value3,value4"
}
```

Loading from AJAX

```json
{
	"id" : "homepage",
	"title" : "Select homepage",
	"description" : "Select the homepage",
	"control" : "collection",
	"defaultValue" : "",
	"ajax" : {
		"url" : "/content/mycollection",
		"displayfield" : "title",
		"valuefield" : "href"
	}
}
```

# Backup / Restore one koda instance to another

Most people want to 'set-up' or create their site on their local machine first and then migrate the content over to production
This couldn't be simpler with koda...

Set up your data and run the following command on your local machine when done...
`ruby data.rb dump data/`
Commit your files or zip them up and place them on production and run the following
`ruby data.rb restore data/koda`

> This will backup /restore all your data and media to file.

### Backup / Restore on Heroku (or other shared hosting)

Take your application into maintenance mode.

Please note: You will need your current `MONGOLAB_URI` (from your Heroku configs) available before you begin as the following steps will alter it permanently.

*   `$ heroku maintenance:on`
    > Run a mongodump of your current database.

*  `$ mongodump -h hostname.mongohq.com:port_number -d database_name -u username -p password -o /path/on/my/local/computer`
    > Deprovision the old database for this app, making sure that the mongodump in Step #2 completed successfully.

*   `$ heroku addons:remove mongolab:starter`
    > Provision a new database for this app.

*   `$ heroku addons:add mongolab:starter`
    > Make available the newly updated MONGOLAB_URI from your Heroku configs.

*   Run a mongorestore of your locally backed up database to your new database (updating your connection info.)
*   `$ mongorestore -h hostname.mongolab.com:port_number -d database_name -u username -p password /path/on/my/local/computer`
*   `$ heroku maintenance:off`

## In Progress / Roadmap

*	Publishing Workflow
*   Preview
*	iPhone and Android starter kit
	- no programming needed, point our app to your koda instance and manage the user interface and content from your admin section
*	Koda Shop starter kit
 	- including Website, Google Checkout integration, iPhone and Android applications
*	Support and Video Tutorials

# Any Questions?

>Koda on Twitter: @kodaframework
>Marcel du Preez on Twitter: @marceldupreez

------------------

# Koka Content API Reference

------------------

## Note about links

All references to other resources follow the json schema format, as specified at http://json-schema.org/json-ref
The only addition is the "title" field, which when present indicates a human readable phrase that is suitable to describe the item.

## Search

Regex Match

`
Request:GET '/api/search?tags=/page/'
Response:[{"href":"/api/pages/homepage","rel":"full"},{"href":"/api/pages/about","rel":"full"},{"href":"/api/pages/contact","rel":"full"}]
`

Exact Match

`
Request:GET '/api/search?tags=home'
Response:[{"href":"/api/pages/homepage","rel":"full"}]
`

Combining

`
Request:GET '/api/search?tags=/page/&someotherproperty=true'
Response:[{"href":"/api/pages/homepage","rel":"full"},{"href":"/api/pages/about","rel":"full"},{"href":"/api/pages/contact","rel":"full"}]
`

Skip and Take

`
Request:GET '/api/search?tags=/page/&someotherproperty=true&skip=1&take=2'
Response:[{"href":"/api/pages/about","rel":"full"},{"href":"/api/pages/contact","rel":"full"}]
`

## Get Requests

###Root Document

'/' returns the a list of urls for the 'user' (non-system) collections, for example

`
Request:GET '/api/'
Response:[{"href":"/trucks","rel":"full"},{"href":"/iguanas","rel":"full"},{"href":"/cars","rel":"full"}]
`

###Collections

'/collectioname' returns a list of urls of the documents stored in the collection, for example

`
Request:GET '/api/trucks'
Response:[{"href":"/trucks/4db0dedb387f7123c9000001","title":"4db0dedb387f7123c9000001","rel":"full"},{"href":"/trucks/smallblueone","title":"smallblueone","rel":"full"}]
`

*Note* The url for a given resource will either be the internal Mongo ID, or a specifically chosen 'friendly' url. This is determined by the field 'alias', discussed further below.
*Note* The value of title will either be '_koda_title', 'alias', or the Mongo ID, in that order or precedence.

###Documents

'/api/collectionname/documentname' returns the Mongo document stored in that collection.
There are two ways documents can be referred to. First is by the internal Mongo ID, for example

`
Request: GET '/api/trucks/4db0dedb387f7123c9000001'
Response: {"size":"big","wheels":4,"colour":"green","alias":"4db0dedb387f7123c9000001"}
`

Secondly is by the 'alias' value, for example
`
Request: GET '/api/trucks/smallblueone'
Response: {"alias":"smallblueone","size":"small","wheels":4,"colour":"blue"}
`

## Post and Put Requests (currently only logged in users)

Documents can be created two ways - either by posting to the collection url, or putting directly to the desired url

###Post

`
Request: POST '/api/bikes' => {'cost':'expensive', 'speed':'fast', 'gears':27 }
Response: Status 201, Location '/bikes/4db0dedb387f7123c9000007'
/bikes/4db0dedb387f7123c9000007
`

*Note* The internally created Mongo ID will usually be used to create the new resource url, returned in the response body and the Location header. This can be override by supplying a value in the 'alias' field. This must be unique to this collection, otherwise a 409 (Conflict) will be returned, along with the url to the conflicting document in the body.

###Put

`
Request: POST '/api/bikes/bigred' => {'cost':'expensive', 'speed':'slow', 'gears':27, 'colour':'red' }
Response: Status 201, Location 'bikes/bigred'
bikes/bigred
`

*Note* If the document did not already exist, the returned status code will be 201 (Created), otherwise 200 (OK)
*Note* If the "alias" field is present in the request, and contradicts, the url posted to, the url will take precedence.

## Delete Requests (currently only logged in users)

### Collections

`
Request: DELETE '/api/trucks'
Response: Status OK
`

### Documents

`
Request DELETE '/api/bikes/bigred'
Response: Status OK
`

## Put and Delete through overloaded Post (currently only logged in users)

In environments where Put and Delete requests are not supported, use this format instead:

`
POST '/api/collectioname/document?_method=METHOD'
`

For example

`
POST '/api/trucks/smallblueone?_method=DELETE' will be interpreted the same as
DELETE '/api/trucks/smallblueone'
`

