---
id: b492d5f2-243a-4d0d-b49c-c437de53e63d
title: Sinatra applications with RSpec
tags: ruby
image: sinatra-app-with-rspec.png
---

There are times when the only thing I want to create is a simple API. In the Ruby ecosystem the standard for creating something simple is Sinatra. But, there are a lot of things you miss in Sinatra that you have predefined in Rails. Sinatra let's you define and include only the things you actually need. Maybe this is a good thing, maybe it is not.

However, the things you need for a complete Sinatra application are sometimes hard to include. This tutorial aims to help you in that process, by showing you how to create a simple Sinatra web application that uses RSpec for testing.

We will create a simple Todo application with only two actions. One for listing all the existing Todos and another one for adding a new one. It will use Sinatra for creating the API, RSpec for testing, and it will also include Active Support for adding a couple of nice functionality to the Ruby language.

## Bootstrap

So let's begin! The first thing is to create a **Gemfile** and list all the dependencies. From the above description of the project we can simply deduct all the things that are necessary.

``` ruby
source "https://rubygems.org"

gem "rack"
gem "sinatra"
gem "activesupport"

group :test do
  gem "rspec"
  gem "rack-test"
end
```

We can install the dependencies with `bundle install`. I like to put my dependencies in the `vendor/bundle` directory. With that the command becomes the following

``` sh
bundle install --path vendor/bundle
```

Then we can initialize RSpec in for project. The following command should create an `.rspec` and a `spec/spec_helper.rb` file.

``` sh
bundle exec rspec --init
```

As an old Rails habit, I like to have two folders in my project. 
- `app` for containing all the application specific files.
- `config` for the project's configuration

Let's create them:

```
mkdir app
mkdir config
```

## Configuration

In this example project I will have only one configuration file called `config/environment.rb`. This file will be responsible for booting up the application and loading all the gems from Bundler. Also it will load and set up active support for this project.

Instead of using a database, this simple API will use only a global variable named `$db`. This is for the sake of simplicity and should be replaced with a real database.

With the above description we can implement that file like this

``` ruby
require "rubygems"
require "bundler"

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems

require "active_support/deprecation"
require "active_support/all"

$db = []                                    # a fake database
```

Now we should make the spec_helper load this file before the tests are run. To do that we need to prepend that file with a require statement.

While we are here it would also be a good idea to set the environment to test when running RSpec, include some rake test helpers, and clear the fake database before each test. 

Your `spec/spec_helper.rb` file should look similar to this.

``` ruby
ENV['RACK_ENV'] = 'test'

require "./config/environment"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    $db = []
  end 

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end 

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end 

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end 

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
```

## The API

As a good TDD abiding citizen we should write some test for our Todo application before actually implementing the code. 

Create an `app/todo_api.rb` and `spec/app/todo_api_spec.rb` file

``` sh
touch app/todo_api.rb
touch spec/app/todo_api_spec.rb
```

and describe the application in your test file

``` ruby
require "spec_helper"

RSpec.describe TodoApi do
  def app
    TodoApi # this defines the active application for this test
  end
end
```

and then a matching class in the app file

``` ruby
class TodoApi < Sinatra::Base

end
```

Then we should create a get action for listing all the todos in the system. Such a get request should return nothing if the database is empty and a list of todos if the contains several todos

``` ruby
describe "GET todos" do      
  context "no todos" do      
    it "returns no todo" do
      get "/"

      expect(last_response.body).to eq("")
      expect(last_response.status).to eq 200
    end
  end

  context "several todos" do
    before do
      @todos = ["hello", "world", "!"]
      $db = @todos
    end

    it "returns all the todos" do   
      get "/"

      expect(last_response.body).to eq @todos.join("\n")
      expect(last_response.status).to eq 200
    end
  end
end
```

A matching implementation would be

``` ruby
get "/" do
  $db.join("\n")
end 
```

Creating a new todo is also simple. The todo message should be passed as an argument to the POST action.

``` ruby
describe "POST todo" do
  it "returns status 200" do
    post "/", :todo => "hello rspec"

    expect(last_response.status).to eq 200
  end

  context "todo param missing" do 
    it "returns status 400" do      
      post "/"

      expect(last_response.status).to eq 400
    end
  end
end
```

It's implementation

``` ruby
post "/" do
  return 400 unless params["todo"].present?

  $db << params["todo"]
  200 
end 
```

## Making rack happy and running the App

In order to run your application with the `rackup` command
we should create an `config.ru` file with the following content

``` ruby
require "./config/environment"

run Rack::URLMap.new("/" => TodoApi)
```

and run our application with

```
bundle exec rackup config.ru
```

Hooray! Our simple API is finished.

Read the full source code [in this GitHub repository](https://github.com/shiroyasha/sinatra_rspec).
