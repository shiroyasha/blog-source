activate :blog do |blog|
  blog.name = "blog"

  blog.permalink = "{title}.html"
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  blog.layout = "article_layout"
  blog.paginate = true
end

page "/sitemap.xml", :layout => false
page "/feed.xml", :layout => false
page "/index.html", :layout => "layout"
page "/about.html", :layout => "about_layout"

ignore "article_layout.erb"
ignore "about_layout.erb"

set :markdown_engine, :redcarpet
set :markdown,
    :tables => true,
    :autolink => true,
    :gh_blockcode => true,
    :fenced_code_blocks => true

activate :syntax

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
end
