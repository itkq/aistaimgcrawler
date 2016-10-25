require 'spec_helper'
require 'webmock/rspec'

IMG_LIST_14_URL = 'http://aikatunews.livedoor.biz/archives/63023672.html'
IMG_1_URL = 'http://livedoor.blogimg.jp/aikatunews/imgs/9/9/991fe707.jpg'
IMG_2_URL = 'http://livedoor.blogimg.jp/aikatunews/imgs/f/6/f6695505.jpg'

describe Aistaimgcrawler::Aikatunews do
  before(:each) do
    index_url = Aistaimgcrawler::Aikatunews.new.index_url
    stub_request(:get, index_url+'?p=1').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'aikatunews_html/1.html'),
    })
    stub_request(:get, index_url+'?p=2').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'aikatunews_html/2.html'),
    })
    stub_request(:get, index_url+'?p=3').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'aikatunews_html/3.html'),
    })
    stub_request(:get, index_url+'?p=4').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'aikatunews_html/4.html'),
    })
    stub_request(:get, IMG_LIST_14_URL).to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'aikatunews_html/img14.html'),
    })
    stub_request(:get, IMG_1_URL).to_return({
      :status => 200,
      :body => File.read(SPEC_DIR+'aikatunews_html/img1.jpg'),
    })
    stub_request(:get, IMG_2_URL).to_return({
      :status => 200,
      :body => File.read(SPEC_DIR+'aikatunews_html/img2.jpg'),
    })
  end

  describe '#get_article_url_by_episode' do
    context 'with existed episode found first' do

      let(:url) { Aistaimgcrawler::Aikatunews.new.get_article_url_by_episode(14) }
      let(:expected) { 'http://aikatunews.livedoor.biz/archives/63023672.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with existed episode found second' do

      let(:url) { Aistaimgcrawler::Aikatunews.new.get_article_url_by_episode(11) }
      let(:expected) { 'http://aikatunews.livedoor.biz/archives/61781734.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with non-existed episode' do

      let(:url) { Aistaimgcrawler::Aikatunews.new.get_article_url_by_episode(99) }
      let(:expected) { nil }

      it 'should return nil' do
        expect(url).to be_eql expected
      end
    end
  end

  describe '#get_img_resources' do
    context 'with existed episode' do
      let(:resources) { Aistaimgcrawler::Aikatunews.new.get_img_resources(14) }

      it 'should be array' do
        expect(resources).to be_a Array
      end

      it 'should not be empty' do
        expect(resources).to_not be_empty
      end
    end

    context 'with non-existed episode' do
      let(:resources) { Aistaimgcrawler::Aikatunews.new.get_img_resources(99) }

      it 'should be nil' do
        expect(resources).to be_nil
      end
    end
  end

  describe '#get_imgs' do

    after(:all) do
      FileUtils.rm_rf(SPEC_DIR+'img/')
    end

    context 'with existed episode' do
      let(:ep) { 14 }
      let(:succ) {
        Aistaimgcrawler::Aikatunews.new(
          Logger.new('/dev/null'), SPEC_DIR+'img/'
        ).get_imgs(ep)
      }

      it 'should be array' do
        expect(succ).to be_a Array
      end

      it 'should have two images' do
        expect(succ.size).to be_eql 2
      end

      it 'should save two images' do
        (1..2).each do |i|
          e = File.exists?(SPEC_DIR+'img/'+("%03d" % ep)+'/00'+i.to_s+'.jpg')
          expect(e).to be_eql true
        end
      end
    end

    context 'with non-existed episode' do
      let(:ep) { 99 }
      let(:succ) {
        Aistaimgcrawler::Aikatunews.new(
          Logger.new('/dev/null'), SPEC_DIR+'img/'
        ).get_imgs(ep)
      }

      it 'should be array' do
        expect(succ).to be_a Array
      end

      it 'should be empty' do
        expect(succ).to be_empty
      end
    end
  end
end
