require 'mechanize'

module Crawler
  class Base
    def initialize logger, img_dir
      @logger    = logger
      @dir       = img_dir
      @thumb_dir = @dir + 'thumb/'
      @mech      = Mechanize.new

      @mech.user_agent_alias = 'Mac Firefox'
    end

    def get_articles
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_episode_title page
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_episode_title ep
      base_url = 'http://www.aikatsu.net/story/' # official
      url = base_url + ("%03d" % ep) + ".html"
      begin
        page = @mech.get(url)
      rescue Mechanize::ResponseCodeError => e
        return nil
      end
      page.search('div.story-img > img').attr('alt').value
    end

    def get_article_url_by_episode ep
      page = 1
      while true
        articles = get_articles(page)
        if articles.empty?
          return nil
        end
        if articles.keys.include?(ep)
          return articles[ep]
        end

        page += 1
      end
    end

    def get_img_resources page
      thumb_res = get_thumbnail_resources(page)
      return nil unless url
      thumb_res.map{|r| r.gsub(/-s\.jpg$/, ".jpg") }
    end

    def get_thumbnail_resources ep
      url = get_article_url_by_episode
      return nil unless url

      page = @mech.get(url)
      body = page.search('div.article-body')
      body.css('img').map{|img|
        url = img.attr('src')
        if (!url.index('images-amazon'))
          url
        end
      }.compact
    end

    def get_imgs url, thumb_flg=false
      @logger.info url
      page = @mech.get(url)
      resources = get_img_resources(page)

      ep = get_episode(page)
      @logger.info "get image from episode #{ep}"
      @logger.info "#{resources.size} images"
      format = "%03d.jpg"

      dirname = @dir + ("%03d" % ep) + "/"

      @logger.info dirname
      unless File.exists?(dirname)
        FileUtils.mkdir(dirname)
      end

      if thumb_flg
        thumb_dirname = @thumb_dir + ("%03d" % ep) + "/"
        unless File.exists?(thumb_dirname)
          FileUtils.mkdir_p(thumb_dirname)
          @logger.info "make thumb dir ##{ep}"
        end
      end

      succ = []
      resources.each_with_index do |_url, i|
        path = dirname + format % [i+1]
        if save_img(path, _url)
          if thumb_flg
            dst = thumb_dirname + format % [i+1]
            reduction(path, dst)
          end

          succ << path
        end
        sleep rand(5)+1
      end

      succ
    end
  end
end
