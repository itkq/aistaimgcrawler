require 'aistaimgcrawler/base'

module Aistaimgcrawler
  class Aikatunews < Aistaimgcrawler::Base
    attr_accessor :index_url

    def initialize logger=$STDOUT, img_dir='./img/'
      super logger, img_dir
      @index_url = 'http://aikatunews.livedoor.biz/archives/cat_252353.html'
    end

    def get_articles p=1
      page = @mech.get @index_url+"?p=#{p}"

      articles = page.search('.article-title').map{|at|
        title = at.css('a').text
        matched = title.match(/第(\d+)話/)
        if matched && title.index('スターズ') && !title.index('文字感想')
          ep = matched[1]
          url = at.css('a').attr('href').value
          [ep.to_i, url]
        end
      }.compact
      Hash[*articles.flatten]
    end

    def get_thumbnail_resources ep
      super(ep, 'livedoor.blogimg.jp/aikatunews')
    end

    def self.get_index_url
     'http://aikatunews.livedoor.biz/archives/cat_252353.html'
    end
  end
end

