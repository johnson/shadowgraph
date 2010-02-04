class CreateRolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false, :force => true do |t|
      t.references :user
      t.references :role

      t.timestamps
    end
    add_index :roles_users, :role_id
    add_index :roles_users, [:user_id, :role_id], :unique => true   
  end

  def self.down
    remove_index :roles_users, :user_id
    remove_index :roles_users, :role_id
    remove_index :roles_users, [:user_id, :role_id]    
    drop_table :roles_users
  end
end
