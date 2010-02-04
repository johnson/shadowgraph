class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :name
      t.string :authorizable_type
      t.integer :authorizable_id

      t.timestamps
    end
    add_index :roles, :name
    add_index :roles, :authorizable_id
    add_index :roles, :authorizable_type
    add_index :roles, [:name, :authorizable_id, :authorizable_type], :unique => true    
  end

  def self.down
    remove_index :roles, [:name, :authorizable_id, :authorizable_type]
    remove_index :roles, :authorizable_type
    remove_index :roles, :authorizable_id
    remove_index :roles, :name    
    drop_table :roles
  end
end
