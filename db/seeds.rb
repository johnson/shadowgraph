['admin', 'owner', 'user'].each { |r| Role.create(:name => r) }
admin = User.create(:login => 'admin', 
                    :email => 'yourmail@example.com', 
                    :password => '123456', 
                    :password_confirmation => '123456', 
                    :state => 'normal')
admin.roles << Role.find_by_name('owner') << Role.find_by_name('admin')