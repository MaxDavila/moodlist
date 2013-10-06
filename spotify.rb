$LOAD_PATH.unshift(File.expand_path('.'))
require 'models/song'
require 'typhoeus'

module Spotify


	def self.query_id(all_tracks, song_title)
		puts "HEYTHERE"
		p all_tracks
		puts "TRACKSSS"
		p all_tracks["tracks"]
		result = all_tracks["tracks"].select { |track| track["name"].include? song_title}
		results_in_us = playable_in_us?(result)
		results_in_us.empty? ? nil : results_in_us[0]["href"].gsub(/spotify:track:/, "")
	end


	def self.get_songs(playlist)
		track_title_array = []
		spotify_playlist = Array.new(playlist.length)
		requests = []
		hydra = Typhoeus::Hydra.new
		# 1. Looks up song in database
		# 2. Populates array with spotify ids, and nils if none
		# 3. If song isn't in database, put in hydra queue
		# 4. Run hydra
		# 5. Populate artist_array with responses
		# 6. Fill in the spotify_playlist nils with the spotify ids from artist_array one by one
		playlist.each_with_index do |song, index|
			track_title_array << song["title"]
			song_in_db = Song.find_or_create_by(artist_name: song["artist_name"], title: song["title"])
			unless song_in_db.spotify_id.nil?
				spotify_playlist[index] = song_in_db.spotify_id
			else
				artist = song["artist_name"]
				artist = URI::escape(artist).gsub(/&/, "and")
				uri = "http://ws.spotify.com/search/1/track.json?q="
				request = URI("#{uri}#{artist}")
				requests << Typhoeus::Request.new(request) 
			end
		end
		
		requests.each { |request| hydra.queue(request)}
		hydra.run
		artist_array = requests.map { |request| JSON.parse(request.response.response_body) }
			spotify_playlist.each_with_index do |song,index|
			if song.nil?
				p spotify_playlist
				puts "ARTISTARRAY at #{index}"
				p artist_array
				artist_tracks = artist_array.shift
				puts "ARTISTTRACKS #{index}"
				p artist_tracks
				title = track_title_array[index]
				spotify_id = query_id(artist_tracks,title)
				spotify_playlist[index] = spotify_id
				song_in_db = Song.where(artist_name: playlist[index]["artist_name"], title: playlist[index]["title"])
				puts "MONKEY"
				p artist_tracks["info"]["query"]
				p title
				p song_in_db
				song_in_db[0].update_attribute(:spotify_id, spotify_id)
			end
		end
		spotify_playlist
	end


	def self.playable_in_us?(result)
		result.select { |track| track["album"]["availability"]["territories"].include?("US") }
	end

end


