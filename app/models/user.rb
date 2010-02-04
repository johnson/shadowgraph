class User < ActiveRecord::Base

  has_many :videos

  has_and_belongs_to_many :roles

  named_scope :being, lambda { |state|
    { :conditions => { :state => state } }
  }

  acts_as_authentic

  # acl9插件的subject模型
  acts_as_authorization_subject

  # attr_accessor :state

  # 用state_mechine插件管理用户状态
  # state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => :pending do
    event :audit       do transition :pending => :normal end
    event :suspend     do transition :normal => :suspended end
    event :unsuspend   do transition :suspended => :normal end
    event :soft_delete do transition all- :soft_deleted => :soft_deleted end
    event :resume      do transition :soft_deleted => :pending end      
  end

end
