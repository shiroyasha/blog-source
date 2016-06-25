---
blog: blog
---
xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "http://shiroyasha.io/"

  xml.title "The path of coding enlightment"
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name "Igor Šarčević" }

  blog.articles[0..5].each do |article|
    xml.entry do
      if article.data[:external] == true
        xml.title article.title
        xml.link "rel" => "alternate", "href" => article.data[:url]
        xml.id article.data[:url]
        xml.published article.date.to_time.iso8601
        xml.updated File.mtime(article.source_file).iso8601
        xml.author { xml.name "Igor Šarčević" }
        xml.summary article.summary, "type" => "html"
      else
        xml.title article.title
        xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
        xml.id URI.join(site_url, article.url)
        xml.published article.date.to_time.iso8601
        xml.updated File.mtime(article.source_file).iso8601
        xml.author { xml.name "Igor Šarčević" }
        xml.summary article.summary, "type" => "html"
        xml.content article.body, "type" => "html"
      end
    end
  end
end
