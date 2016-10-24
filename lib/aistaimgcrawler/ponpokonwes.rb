require 'aistaimgcrawler/base'

module Aistaimgcrawler
  class Ponpokonwes < Aistaimgcrawler::Base
    INDEX_URL = 'http://ponpokonwes.blog.jp/archives/cat_888546.html'

    def initialize logger=$STDOUT, img_dir='./img/'
      super logger, img_dir
    end

    def get_articles page=1
      page = @mech.get INDEX_URL+"?p=#{page}"

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
  end
end

