require 'spec_helper'
require 'webmock/rspec'

SPEC_DIR = './spec/aistaimgcrawler/'
INDEX_URL = 'http://ponpokonwes.blog.jp/archives/cat_888546.html'

describe Aistaimgcrawler::Base do
  describe '#get_article_url_by_episode' do
    context 'with existed episode found first' do
      before do
        stub_request(:get, INDEX_URL+'?p=1').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/1.html'),
        })
      end

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(28) }
      let(:expected) { 'http://ponpokonwes.blog.jp/archives/66727377.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with existed episode found second' do
      before do
        stub_request(:get, INDEX_URL+'?p=1').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/1.html'),
        })
        stub_request(:get, INDEX_URL+'?p=2').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/2.html'),
        })
      end

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(22) }
      let(:expected) { 'http://ponpokonwes.blog.jp/archives/65698560.html' }

      it 'should return correct url' do
        expect(url).to be_eql expected
      end
    end

    context 'with non-existed episode' do
      before do
        stub_request(:get, INDEX_URL+'?p=1').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/1.html'),
        })
        stub_request(:get, INDEX_URL+'?p=2').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/2.html'),
        })
        stub_request(:get, INDEX_URL+'?p=3').to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(SPEC_DIR+'ponpokonwes_html/3.html'),
        })
      end

      let(:url) { Aistaimgcrawler::Ponpokonwes.new.get_article_url_by_episode(30) }
      let(:expected) { nil }

      it 'should return nil' do
        expect(url).to be_eql expected
      end
    end
  end
end
