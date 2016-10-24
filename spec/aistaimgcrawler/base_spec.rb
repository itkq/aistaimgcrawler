require 'spec_helper'
require 'webmock/rspec'

# WebMock.allow_net_connect!

VALID_STORY_URL = 'http://www.aikatsu.net/story/001.html'
INVALID_STORY_URL = 'http://www.aikatsu.net/story/999.html'
BASE_SPEC_DIR = './spec/aistaimgcrawler/'

describe Aistaimgcrawler::Base do
  describe '#get_episode_title' do
    context 'with existed episode' do
      before do
        stub_request(:get, VALID_STORY_URL).to_return({
          :status => 200,
          :headers => {content_type: 'text/html'},
          :body => File.read(BASE_SPEC_DIR+'base_html/001.html'),
        })
      end

      let(:title) { Aistaimgcrawler::Base.new($STDOUT,'dummy').get_episode_title(1) }
      let(:expected) { 'ゆめのはじまり' }

      it 'should return correct title' do
        expect(title).to be_eql expected
      end
    end

    context 'with non-existed episode' do
      before do
        stub_request(:get, INVALID_STORY_URL).to_return({
          :status => 404,
          :headers => {content_type: 'text/html'},
          :body => File.read(BASE_SPEC_DIR+'base_html/999.html'),
        })
      end

      let(:title) { Aistaimgcrawler::Base.new($STDOUT,'dummy').get_episode_title(999) }
      let(:expected) { nil }

      it 'should return correct title' do
        expect(title).to be_eql expected
      end
    end
  end
end
