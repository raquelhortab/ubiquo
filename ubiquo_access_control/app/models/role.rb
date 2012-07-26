class Role < ActiveRecord::Base
  has_many :role_permissions, :dependent => :destroy
  has_many :permissions, :through => :role_permissions

  has_many :ubiquo_user_roles, :dependent => :destroy
  has_many :ubiquo_users, :through => :ubiquo_user_roles

  validates :name, :presence => true

  attr_accessible :name

end
