require 'typhoeus'
module Echonest


    def self.prepare_uri(current_mood, desired_mood, style, x, y)
        uri_string = "http://developer.echonest.com/api/v4/playlist/static?api_key=AUAC13N6YQZ5F1XMD" +
        "&mood=#{current_mood}^#{x}"+
        "&mood=#{desired_mood}^#{y}"+
        "&style=#{style}^5"+
        "&results=50" +
        "&type=artist-description" +
        "&song_type=studio"+
        "&song_min_hotttnesss=0.2"+
        "&artist_min_hotttnesss=0.2"+
        "&sort=song_hotttnesss-desc"
        uri_address = URI(URI.encode(uri_string))
    end
   
    def self.get_songs(current_mood,desired_mood, style)
        mood_hash = {
            3 => 0.1,
            2.8 => 0.3,
            2.6 => 0.5,
            2.4 => 0.7,
            2.2 => 0.9,
            2.0 => 1.1,
            1.8 => 1.3,
            1.6 => 1.5,
            1.4 => 1.7,
            1.2 => 1.9,
            1.0 => 2.1,
            0.8 => 2.3,
            0.6 => 2.5,
            0.4 => 2.7,
            0.2 => 2.9,
            0 => 3.1
        }

        hydra = Typhoeus::Hydra.new
        echonest_uris = mood_hash.map do |x,y|
          prepare_uri(current_mood,desired_mood,style,x, y)
        end

        requests = echonest_uris.map { |uri| Typhoeus::Request.new(uri) }
        requests.each { |request| hydra.queue(request)}
        hydra.run
        song_array = requests.map { |request| JSON.parse(request.response.response_body) }
        song_array.map { |song| song["response"]["songs"] }
    end

end


