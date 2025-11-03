class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end
  
  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
  
  def self.find_in_tmdb(title_with_date, release_year = nil, language = 'all', api_key = 'f68bb46a3b39baecdb866e452b8e662e')

    if title_with_date.is_a?(Hash)
      options = title_with_date
      title_with_date = options[:title]
      year = options[:year]
      language = options[:language]
    else
      title = title_with_date
    end
    
    url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{URI.escape(title_with_date)}"
    
    url += "&year=#{release_year}" if release_year.present?
    
    url += "&language=en-US" if language == 'en'
    
    search_response = Faraday.get(url)
    search_results = JSON.parse(search_response.body)['results'] || []

    search_results.map do |movie_data|
      movie_id = movie_data['id']
    
      release_response = Faraday.get("https://api.themoviedb.org/3/movie/#{movie_id}/release_dates?api_key=#{api_key}")
      release_results = JSON.parse(release_response.body)['results']

      rating = release_results&.find { |r| r['iso_3166_1'] == 'US' }&.dig('release_dates', 0, 'certification') || "PG"

      Movie.new(
        title: movie_data['title'],
        rating: rating,
        release_date: movie_data['release_date'],
        description: movie_data['overview']
      )
    end
  end
  
end