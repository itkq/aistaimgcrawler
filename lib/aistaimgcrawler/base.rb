require 'mechanize'
require 'logger'
require 'ruby-progressbar'

module Aistaimgcrawler
  class Base
    STORY_URL = 'http://www.aikatsu.net/story/' # official

    def initialize logger, img_dir
      @logger    = logger
      @dir       = img_dir
      @thumb_dir = @dir + 'thumb/'
      @mech      = Mechanize.new

      @mech.user_agent_alias = 'Mac Firefox'
      $stdout.sync = true
    end

    def get_articles
      raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
    end

    def get_episode_title ep
      url = STORY_URL + ("%03d" % ep) + ".html"
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

    def get_img_resources ep
      thumb_res = get_thumbnail_resources(ep)
      return nil unless thumb_res
      thumb_res.map{|r| r.gsub(/-s\.jpg$/, ".jpg") }
    end

    def get_thumbnail_resources ep, include_url=''
      url = get_article_url_by_episode(ep)
      return nil unless url

      page = @mech.get(url)
      body = page.search('div.article-body')
      body.css('img').map{|img|
        url = img.attr('src')
        next if (url.index('images-amazon'))
        unless include_url.empty?
          url if url.index(include_url)
        else
          url
        end
      }.compact
    end

    def get_imgs ep, size=nil, thumb_flg=false
      resources = get_img_resources(ep)
      return [] unless resources

      if size.to_i > 0
        resources = resources[0..size.to_i-1]
      end

      @logger.info "get image from episode #{ep}"
      @logger.info "#{resources.size} images"
      format = "%03d.jpg"

      dirname = @dir + ("%03d" % ep) + "/"

      @logger.info dirname
      unless File.exists?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      if thumb_flg
        thumb_dirname = @thumb_dir + ("%03d" % ep) + "/"
        unless File.exists?(thumb_dirname)
          FileUtils.mkdir_p(thumb_dirname)
          @logger.info "make thumb dir ##{ep}"
        end
      end

      succ = []
      pb = create_pb(resources.size-1)
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
        pb.increment
      end

      succ
    end

    def save_img path, url
      begin
        @mech.get(url).save_as(path)
      rescue => e
        @logger.warn e.message
        return false
      end

      @logger.info "#{url} ==> finished"
      true
    end

    def create_pb total
      ProgressBar.create(
        total:         total,
        format:        '%a %B %p%% %t',
        progress_mark: '#',
      )
    end
  end
end
