activate :blog do |blog|
  blog.name = "blog"

  blog.permalink = "{title}.html"
  blog.sources = "posts/{title}.html"
  blog.layout = "article_layout"
  blog.paginate = true
end

page "/sitemap.xml", :layout => false
page "/feed.xml", :layout => false
page "/index.html", :layout => "layout"
page "/about.html", :layout => "layout"

ignore "article_layout.erb"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :syntax

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end
