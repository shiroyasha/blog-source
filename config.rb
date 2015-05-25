###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.name = "blog"

  blog.permalink = "{title}.html"
  # Matcher for blog source files
  blog.sources = "posts/{title}.html"
  # blog.taglink = "tags/{tag}.html"
  blog.layout = "article_layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  # blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

activate :blog do |blog|
  blog.name = "tips"

  blog.permalink = "tips/{title}.html"
  blog.sources = "tips/posts/{title}.html"

  blog.paginate = true
  blog.layout = "tip_layout"
end

page "/sitemap.xml", :layout => false
page "/feed.xml", :layout => false
page "/index.html", :layout => "layout"

ignore "article_layout.erb"
ignore "tip_layout.erb"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
activate :syntax

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
#  activate :imageoptim do |options|
#    # Silence problematic image_optim workers
#    options.skip_missing_workers = true
#
#    # Setting these to true or nil will let options determine them (recommended)
#    options.nice = true
#    options.threads = true
#
#    # Image extensions to attempt to compress
#    options.image_extensions = %w(.png .jpg .gif .svg)
#
#    # Compressor worker options, individual optimisers can be disabled by passing
#    # false instead of a hash
#    options.advpng    = { :level => 4 }
#    options.gifsicle  = { :interlace => false }
#    options.jpegoptim = { :strip => ['all'], :max_quality => 100 }
#
#    options.jpegtran  = { :copy_chunks => false,
#                          :progressive => true,
#                          :jpegrescan => true }
#
#    options.optipng   = { :level => 6, :interlace => false }
#    options.pngcrush  = { :chunks => ['alla'], :fix => false, :brute => false }
#    options.pngout    = false
#    options.svgo      = false
#  end
end
