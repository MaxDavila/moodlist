class UpdatePlaylistTable < ActiveRecord::Migration
  def up
    change_column :playlists, :playlist_url, :text, :limit => nil
  end

  def down
  end
end
