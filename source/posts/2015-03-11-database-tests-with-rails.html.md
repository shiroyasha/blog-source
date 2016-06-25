---
title: Database Tests with Rails
date: 2015-03-11
tags: ruby
image: database.png
---

We, software developers, like to call ourselves computer scientist,
software engineers or data scientists. Hah, what a load of bulls*it!

To do real science, we would need to be able to measure, reproduce and
prove our code and methodologies. But I will leave this discussion for
an another day...

The reason why I started like this is because I often find
myself guessing and hoping for the best instead of doing the hard work,
and actually trying to measure and test my ideas.

One particular area, where I often fail to live up to a good scientific
practice, is estimating the duration of database actions. But no more!
In this article I will explain how I test some of my guesses by
creating short lived Rails projects with some sample databases.

## Creating Test Projects

I start each test session by creating a test project with Rails,
usually with a preset database:

``` sh
rails new db-test-1 --database=postgresql
```

Then I follow up with creating an appropriate model that fits my
testing needs. For example a Movies table:

``` sh
rails generate model movies title:string genre:string description:text
rake db:migrate
```

The finishing step is of course to create some data in the database.
I like to make a big number of entries because that way the errors
in my logic are easily exposed. For example a million entries are
a good test candidate. We can make them in the Rails console.

But because this action usually takes more than a couple of minutes,
I like to turn of the Rails logger with the following command before
I create the entries to prevent unnecessary overhead:

``` rb
ActiveRecord::Base.logger.level = 1
```

To return the origin logger state I will execute the following:

``` rb
ActiveRecord::Base.logger.level = 0
```

For the above `movies` table I would write something like this:

``` sh
genres = ["action", "commedy", "thriller"]

1000000.times do |index|
  Movies.create :title => "movie-#{index}",
                :genre => genres.sample,
                :description => "#{SecureRandom.uuid * 100}"

  # progress indicator
  puts(index) if index % 1000 == 0
end
```

This is of course pretty basic if you have used Rails for more
than a week or two, but it is a necessary boilerplate. Let's 
start with the measurement.

## Adding New Columns

For example we can create some migrations that add a new column to
the `movies` table.

``` sh
rails generate migration AddDirectorToMovies
```

``` ruby
def change
  add_column :movies, :director, :string
end
```

On my computer this takes less than a second to finish.

``` sh
$ rake db:migrate

-- add_column(:movies, :director, :string)
   -> 0.0315s
```

However if I add a default value on the director column:

``` ruby
def change
  add_column :movies, :director, :default => "Nobody"
end
```

Than it takes significantly longer:

``` sh
$ rake db:migrate

-- add_column(:movies, :director, :string, {:default=>"Nobody"})
   -> 24.7215s
```

This was of course expected, but if you would ask me before
this test, I would guess that the time difference is not this
big. Measurements ftw!

## Adding Database Indexes

Adding indexes to the database can often speed up your queries.
But will it always speed them up? Let's find out with a simple
example.

For example let's try to speed up the following query:

``` sh
> Movie.where(:genre => "action").count
(157.8ms)  SELECT COUNT(*) FROM "movies"  WHERE "movies"."genre" = 'action'
=> 332953
```

It isn't too slow, but if we execute several of these counts in
one HTTP request, it can add up quickly.

Let's add an index to it:

``` sh
rails generate migration AddIndexToMoviesGenre
```

``` ruby
def change
  add_index :movies, :genre 
end
```

Execute it with the following:

```
$ rake db:migrate
== 20150311212758 AddIndexToMoviesGenre: migrating 
-- add_index(:movies, :genre)
   -> 31.1195s
== 20150311212758 AddIndexToMoviesGenre: migrated (31.1196s)
```

Whooa! I did not expect more than a couple of seconds for this
task. But let's continue. Will it speed up the query?

``` sh
> Movie.where(:genre => "action").count
(161.4ms)  SELECT COUNT(*) FROM "movies"  WHERE "movies"."genre" = 'action'
=> 332953
```

Bummer, it did not help at all! As I later checked, it is pretty
much useless to add indexes to column that have a small range of
values. That is of course exactly the case with the genre column.

## Final words

The above tests are probably a little childish, but some of the
things actually surprised me. I hope you liked this article.

Happy hacking!
