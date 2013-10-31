class Playlist < ActiveRecord::Base
	belongs_to :user
  validates_uniqueness_of :playlist_url, :scope => :user_id

end


