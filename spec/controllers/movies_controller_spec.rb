require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do
    describe 'searching TMDb' do
      before :each do
        @fake_results = [double('movie1'), double('movie2')]
      end
      it 'calls the model method that performs TMDb search' do
        expect(Movie).to receive(:find_in_tmdb).with('hardware').
         and_return(@fake_results)
       get :search_tmdb, {:search_terms => 'hardware'}
     end
     describe 'after valid search' do
       before :each do
         allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
         get :search_tmdb, {:search_terms => 'hardware'}
       end
       it 'selects the Search Results template for rendering' do
         expect(response).to render_template('search_tmdb')
       end
       it 'makes the TMDb search results available to that template' do
         expect(assigns(:movies)).to eq(@fake_results)
       end
     end
   end
    describe 'add_movie' do
        it 'creates a new movie in the database' do
            movie_params = {
            movie: {
                title: 'Transformers',
                rating: 'PG-13',
                release_date: '2007-07-03',
                description: 'Im going to turn into a truck now. Pack it up pack it in chor chor chor chor ching'
            }
            }
            
            expect {
                post :add_movie, movie_params
            }.to change(Movie, :count).by(1)
        end

        it 'redirects to search_tmdb after adding movie' do
            movie_params = {
            movie: {
                title: 'Transformers',
                rating: 'PG-13',
                release_date: '2007-07-03',
                description: 'Im going to turn into a truck now. Pack it up pack it in chor chor chor chor ching'
            }
            }
            
            post :add_movie, movie_params
            expect(response).to redirect_to(search_tmdb_path)
        end

        it 'sets a flash notice with the movie title' do
            movie_params = {
            movie: {
                title: 'Transformers',
                rating: 'PG-13',
                release_date: '2007-07-03',
                description: 'Im going to turn into a truck now. Pack it up pack it in chor chor chor chor ching'
            }
            }
            
            post :add_movie, movie_params
                expect(flash[:notice]).to eq('Transformers was successfully added to RottenPotatoes.')
        end
    end
end