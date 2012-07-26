class Permission < ActiveRecord::Base
  has_many :role_permissions
  has_many :roles, :through => :role_permissions

  validates :key, :uniqueness => { :case_sensitive => false }
  validates :key, :format => { :with => /\A[a-z\_]*\Z/ }
  validates :name, :key, :presence => true

  attr_accessible :name, :key

  # Magic finder. it's like an find_by_id_or_key
  def self.gfind(something, options={})
    case something
    when Fixnum
      find_by_id(something, options)
    when String, Symbol
      find_by_key(something.to_s, options)
    when Permission
      something
    else
      nil
    end
  end
end
