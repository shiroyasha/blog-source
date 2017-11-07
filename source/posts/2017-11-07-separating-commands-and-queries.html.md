---
id: 01137854-b807-4877-aab1-78a4c9ff0d25
title: Separating Commands and Queries
date: 2017-11-07
tags: programming
image: separating-commands-and-queries.jpg
---

I have learned an important lesson this year. A clear separation between queries
and commands can bring a lot of long term benefits to your code.

![Separating Commands and Queries](images/separating-commands-and-queries.jpg)

Let me start with an example to showcase the essence of this approach. In a book
retail application, we want to lower the price of books that have sold less than
100 copies this year. One approach to implement it would be the following:

``` ruby
def disscount_poor_performing_books(books)
  books.each do |book|
    if book.copies_sold_this_year < 100
      book.price = book.price * 0.8
    end
  end
end
```

How can we improve it?

Imagine that you are an administrator of this book management system. Would you
feel comfortable to click on a button that executes this change in your system?
Probably not. You would first like to see a list the of books that will be
affected by this change.

Let's rewrite the above code to make this possible.

``` ruby
def books_for_discount(books)
  books.select { |book| book.copies_sold_this_year < 100 }
end

def give_disscount(books)
  books.each { |book| give_disscount(book) }
end
```

Now, you can use the `books_for_discount` to display the list of books that will
be affected when the button is clicked by our administrator. When the
administrator decides to click on the button, we can execute `give_disscount` on
that list of books.

## Generalizing the separation for a wide range of issues

There is an underlying pattern in the above example that can be generalized to a
wide range of problems.

The first implementation `disscount_poor_performing_books` _combined_ the
selection of the books with the _update_ on the books.

The second approach, separated the _query_ `books_for_discount` from the
_execution_ `give_disscount`. This separation allowed us to gain more control
over the process.

As a rule of thumb, when I design background processes, I always make sure to
separate these two concerns. I do this even if there is no immediate reason for
this separation. This keeps my system modular and allows future maintainers to
inject various observation or metric in the processes I develop.

## Benefits of query command separation

Apart from the benefit described in the previous chapter, this separation has
some other benefits that are worth noting.

1. The query part of the process is usually side-effect free. This reduces the
size of the code that can be potentially dangerous, and we can be more relaxed
when invoking the query part of the process.

2. The separation tends to make the code easier to test.

3. Additional queries can be introduced in the process more easily. In the
example from the start, this would allow giving discounts based on other
criteria without changing the code that gives the discount.

_Did you like this article? Or, do you maybe have a helpful hint to share?
Please leave it in the comment section bellow._
