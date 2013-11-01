$LOAD_PATH.unshift(File.expand_path('.'))
require 'models/song'
require 'typhoeus'
module Spotify

	def self.check_if_spotify_has_song(all_tracks, song_title)
		result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
		results_in_us = playable_in_us?(result)
		results_in_us.empty? ? nil : results_in_us[0]["href"].gsub(/spotify:track:/, "")
	end

	def self.prepare_uri(song)
		artist = song["artist_name"]
		artist = URI::escape(artist).gsub(/&/, "and")
		uri = "http://ws.spotify.com/search/1/track.json?q="
		URI("#{uri}#{artist}")
	end

	def self.query_spotify(uri_array)
		mutex = Mutex.new
		spotify_id_array = []
		uri_array.map do |uri_song|
			Thread.new do
				response = Net::HTTP.get(uri_song[0])
				artist_tracks = JSON.parse(response)
				mutex.synchronize do
					spotify_id_array << check_if_spotify_has_song(artist_tracks, uri_song[1].title)
				end
			end
		end.each { |thread| thread.join }
		spotify_id_array
	end

	def self.update_db_and_get_song_ids(playlist, spotify_id_array)
		playlist.map! do |song|
			if song.spotify_id.nil?
				spotify_id = spotify_id_array.shift
				song.update_attribute(:spotify_id, spotify_id)
			end
			song.spotify_id
		end
	end

	def self.get_songs(playlist)
		uri_array = []
		playlist.map! do |song|
			song_in_db = Song.find_or_create_by(artist_name: song["artist_name"], title: song["title"])
			if song_in_db.spotify_id.nil?
				uri_array << [prepare_uri(song), song_in_db]
			end
			song_in_db
		end
		spotify_id_array = query_spotify(uri_array)
		update_db_and_get_song_ids(playlist, spotify_id_array)

	end


	def self.playable_in_us?(result)
		result.select { |track| track["album"]["availability"]["territories"].include?("US") }
	end

end


