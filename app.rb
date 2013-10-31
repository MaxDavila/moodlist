$LOAD_PATH.unshift(File.expand_path('.'))
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'net/http'
require 'models/user'
require 'models/playlist'
require 'config/dotenv_helper'
require 'config/omniauth_helper'
require 'playlist_creator'
require 'option_arrays'

set :database, ENV["DATABASE_URL"] || 'sqlite3:///moodlist.db'


enable :sessions

get '/' do
  if is_not_logged_in?
    erb :login
  else
    @first_name = get_first_name
    @profile_pic_url = get_profile_pic
    @current_mood  = "sad"
    @desired_mood  = "happy"
    @style = "pop"
    @container_id = "home"
    @saved_playlists = get_playlists
    erb :home
  end
end

get '/auth/:provider/callback' do
 uid = request.env['omniauth.auth'][:uid]
 first_name = request.env['omniauth.auth']['info'][:first_name]
 last_name = request.env['omniauth.auth']['info'][:last_name]
 profile_pic_url = request.env['omniauth.auth']['info'][:image]
 user = User.find_or_create_by(facebook_uid: uid)
 user.update_attributes(first_name: first_name, last_name: last_name, profile_pic_url: profile_pic_url)

 session[:facebook_uid] = request.env['omniauth.auth'][:uid]
 redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/search' do
  if params[:saved_playlist]
    playlist = current_user.playlists.find_by(name: params[:saved_playlist])
    @spotify_url = playlist.playlist_url
    get_playlist_name(params[:saved_playlist])
  else
    songs = PlaylistCreator.get_playlist(params)
    @spotify_url = "https://embed.spotify.com/?uri=spotify:trackset:Your customized playlist:#{songs.join(',')}"
    @current_mood  = params[:current_mood]
    @desired_mood  = params[:desired_mood]
    @style = params[:style]
  end
  @first_name = get_first_name
  @user_id = get_user_id
  @profile_pic_url = get_profile_pic
  @container_id =""
  @saved_playlists = get_playlists
  erb :home
end

post '/saveplaylist' do
  date = DateTime.now
  user = User.find(params[:user_id])

  playlist = Playlist.create(playlist_url: params[:playlist_url], name: "#{date.strftime('%m.%d.%y')} | #{params[:playlist_name]}")
  user.playlists << playlist
  playlist.name
end


helpers do

  def is_not_logged_in?
    session[:facebook_uid].nil?
  end

  def get_first_name
    current_user.first_name
  end

  def get_user_id
    current_user.id
  end

  def get_profile_pic
    current_user.profile_pic_url
  end

  def get_playlists
    current_user.playlists
  end

  def current_user
    current_user = current_user || User.find_by_facebook_uid(session[:facebook_uid]) unless is_not_logged_in?
  end

  def get_playlist_name(playlist_name)
    playlist_array = playlist_name.split(" ")
    @current_mood = playlist_array[4]
    @desired_mood = playlist_array[6]
    @style = playlist_array[2]
  end

end



