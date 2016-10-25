require 'aistaimgcrawler/base'

module Aistaimgcrawler
  class Ponpokonwes < Aistaimgcrawler::Base
    attr_accessor :index_url

    def initialize logger=$STDOUT, img_dir='./img/'
      super logger, img_dir
      @index_url = 'http://ponpokonwes.blog.jp/archives/cat_888546.html'
    end

    def get_articles p=1
      page = @mech.get @index_url+"?p=#{p}"

      articles = page.search('.article-title').map{|at|
        matched = at.css('a').text.match(/第(\d+)話/)
        if matched
          ep = matched[1]
          url = at.css('a').attr('href').value
          [ep.to_i, url]
        end
      }.compact
      Hash[*articles.flatten]
    end

    def get_thumbnail_resources ep
      super(ep, 'livedoor.blogimg.jp/ponpokonwes')
    end

  end
end

