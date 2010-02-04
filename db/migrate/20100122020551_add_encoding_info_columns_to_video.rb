class AddEncodingInfoColumnsToVideo < ActiveRecord::Migration   
  def self.up
    add_column :videos, :queued_at, :datetime
    add_column :videos, :started_encoding_at, :datetime
    add_column :videos, :encoding_time, :time
    add_column :videos, :encoded_at, :datetime
  end

  def self.down
    remove_column :videos, :queued_at
    remove_column :videos, :started_encoding_at
    remove_column :videos, :encoding_time
    remove_column :videos, :encoded_at
  end
end
