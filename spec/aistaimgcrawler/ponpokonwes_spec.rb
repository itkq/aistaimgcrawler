require 'spec_helper'
require 'webmock/rspec'

PONPOKO_IMG_LIST_28_URL = 'http://ponpokonwes.blog.jp/archives/66727377.html'
PONPOKO_IMG_1_URL = 'http://livedoor.blogimg.jp/ponpokonwes/imgs/7/0/70788bdd.jpg'
PONPOKO_IMG_2_URL = 'http://livedoor.blogimg.jp/ponpokonwes/imgs/d/3/d3e71576.jpg'

describe Aistaimgcrawler::Ponpokonwes do
  before(:each) do
    index_url = Aistaimgcrawler::Ponpokonwes.new.index_url
    stub_request(:get, index_url+'?p=1').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'ponpokonwes_html/1.html'),
    })
    stub_request(:get, index_url+'?p=2').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'ponpokonwes_html/2.html'),
    })
    stub_request(:get, index_url+'?p=3').to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'ponpokonwes_html/3.html'),
    })
    stub_request(:get, PONPOKO_IMG_LIST_28_URL).to_return({
      :status => 200,
      :headers => {content_type: 'text/html'},
      :body => File.read(SPEC_DIR+'ponpokonwes_html/img28.html'),
    })
    stub_request(:get, PONPOKO_IMG_1_URL).to_return({
      :status => 200,
      :body => File.read(SPEC_DIR+'ponpokonwes_html/img1.jpg'),
    })
    stub_request(:get, PONPOKO_IMG_2_URL).to_return({
      :status => 200,
      :body => File.read(SPEC_DIR+'ponpokonwes_html/img2.jpg'),
    })
  end

  describe '#get_article_url_by_episode' do
    context 'with existed episode found first' do

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(28) }
      let(:expected) { 'http://ponpokonwes.blog.jp/archives/66727377.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with existed episode found second' do

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(22) }
      let(:expected) { 'http://ponpokonwes.blog.jp/archives/65698560.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with non-existed episode' do

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(30) }
      let(:expected) { nil }

      it 'should return nil' do
        expect(url).to be_eql expected
      end
    end
  end

  describe '#get_img_resources' do
    context 'with existed episode' do
      let(:resources) { Aistaimgcrawler::Ponpokonwes.new.get_img_resources(28) }

      it 'should be array' do
        expect(resources).to be_a Array
      end

      it 'should not be empty' do
        expect(resources).to_not be_empty
      end
    end

    context 'with non-existed episode' do
      let(:resources) { Aistaimgcrawler::Ponpokonwes.new.get_img_resources(99) }

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
      let(:ep) { 28 }
      let(:succ) {
        Aistaimgcrawler::Ponpokonwes.new(
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
        Aistaimgcrawler::Ponpokonwes.new(
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
