require 'helpers/echonest'
require 'helpers/spotify'

module PlaylistCreator
  def self.get_playlist(params)
    current_mood = URI::escape(params[:current_mood])
    desired_mood = URI::escape(params[:desired_mood])
    style = URI::escape(params[:style])
    playlist = populate_playlist(current_mood,desired_mood,style)
    Spotify.get_songs(playlist)
  end

  def self.populate_playlist(current_mood,desired_mood,style)
    playlist = []
    song_array_matrix = Echonest.get_songs(current_mood,desired_mood, style)
    p song_array_matrix
      song_array_matrix.each do |song_array|
        playlist = make_unique_playlist(song_array,playlist)
      end
    playlist
  end

  def self.make_unique_playlist(song_array, playlist)
    p song_array
    song_array.each do |song|
      unless in_playlist_array?(playlist, song)
        playlist << song
        break
      end
    end
    playlist
  end

  def self.in_playlist_array?(playlist, song)
    playlist.each do |playlist_song|
      return true if (playlist_song["title"].upcase == song["title"].upcase)
    end
    return false
  end

end
