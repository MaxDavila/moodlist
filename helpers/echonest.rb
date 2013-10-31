require 'thread'
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
    URI(URI.encode(uri_string))
  end

  def self.get_song_array(echonest_responses)
    song_array = echonest_responses.map { |echonest_response| JSON.parse(echonest_response) }
    song_array.map { |song| song["response"]["songs"] }
  end

  def self.get_desired_mood_level(x)
    3.1 - x
  end

  def self.get_songs(current_mood,desired_mood, style)
    current_mood_level = 3.0
    interval = 0.2
    echonest_uris = []

    while current_mood_level > 0
      desired_mood_level = get_desired_mood_level(current_mood_level)
      echonest_uris << prepare_uri(current_mood,desired_mood,style, current_mood_level, desired_mood_level)
      p current_mood_level -= interval
    end
    echonest_responses = []

    echonest_uris.map do |uri|
      Thread.new { echonest_responses << Net::HTTP.get(uri) }
    end.each { |thread| thread.join }
    get_song_array(echonest_responses)
  end

end


