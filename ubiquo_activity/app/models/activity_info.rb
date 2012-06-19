class ActivityInfo < ActiveRecord::Base

  validates :controller, :presence => true
  validates :action, :presence => true
  validates :status, :presence => true
  validates :ubiquo_user_id, :presence => true

  belongs_to :related_object, :polymorphic => true
  belongs_to :ubiquo_user

  scope :controller,  lambda { |value| where(:controller => value)}
  scope :action,      lambda { |value| where(:action => value)}
  scope :status,      lambda { |value| where(:status => value)}
  scope :date_start,  lambda { |value| where("created_at >= ?", value)}
  scope :date_end,    lambda { |value| where("created_at <= ?", value)}
  scope :user,        lambda { |value| where(:ubiquo_user_id => value)}

  filtered_search_scopes :enable => [:controller, :action, :status, :date_start, :date_end, :user]

  def related_object
    if related_object_type && related_object_id
      super || recover_object
    end
  end

  def related_object_name
    related_object.class.name.underscore.to_sym if related_object
  end

  protected

  def recover_object
    nil
  end
end


