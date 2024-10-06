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
page "/about-me.html", :layout => "about_layout"

ignore "article_layout.erb"
ignore "about_layout.erb"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :external_pipeline,
  name: :tailwind,
  command: "npx tailwindcss -i ./source/stylesheets/site.css -o ./dist/stylesheets/site.css #{"--watch" unless build?}",
  latency: 2,
  source: "./dist/"

activate :syntax


set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_javascript
end

helpers do
  def nav_link(link_text, url, options = {})
    options[:class] ||= ""
    options[:class] << " active" if url == current_page.url
    link_to(link_text, url, options)
  end
end
