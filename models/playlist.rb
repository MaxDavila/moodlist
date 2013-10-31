class Playlist < ActiveRecord::Base 
	belongs_to :user
	# validates :name, presence: true, length: {minimum: 2, maximum: 30, message: "Must be between 2 and 30 characters"}
  
end


