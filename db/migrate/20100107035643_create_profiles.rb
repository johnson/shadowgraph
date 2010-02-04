class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :title, :limit => 40
      t.string :player, :limit => 40
      t.string :container, :limit => 40
      t.integer :width
      t.integer :height
      t.string :video_codec, :limit => 40
      t.integer :video_bitrate
      t.integer :fps
      t.string :audio_codec, :limit => 40
      t.integer :audio_bitrate
      t.integer :audio_sample_rate
      t.string :position, :limit => 40

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
