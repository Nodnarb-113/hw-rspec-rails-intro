require 'rails_helper'
require 'spec_helper'


describe Movie do
  describe 'searching Tmdb by keyword' do
    it 'calls Faraday with the TMDb API URL' do
      fake_response = double('response', body: '{"results": []}')
      
      expect(Faraday).to receive(:get).with(/api\.themoviedb\.org.*query=Inception/).and_return(fake_response)
      
      Movie.find_in_tmdb('Inception')
    end
    
    it 'includes the release year in the URL when provided' do
      fake_response = double('response', body: '{"results": []}')
      
      expect(Faraday).to receive(:get).with(/year=2010/).and_return(fake_response)
      
      Movie.find_in_tmdb('Inception', '2010')
    end
    
    it 'includes language parameter when set to English' do
      fake_response = double('response', body: '{"results": []}')
      
      expect(Faraday).to receive(:get).with(/language=en-US/).and_return(fake_response)
      
      Movie.find_in_tmdb('Inception', nil, 'en')
    end

    it 'calls Tmdb with valid API key' do
      Movie.find_in_tmdb({title: "hacker", language: "en"})
    end
  end
end