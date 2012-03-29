class ActivityInfo < ActiveRecord::Base

  validates :controller, :presence => true
  validates :action, :presence => true
  validates :status, :presence => true
  validates :ubiquo_user_id, :presence => true

  belongs_to :related_object, :polymorphic => true
  belongs_to :ubiquo_user

  scope :controller, lambda { |value| where(:controller => value)}
  scope :action,     lambda { |value| where(:action => value)}
  scope :status,     lambda { |value| where(:status => value)}
  scope :date_start, lambda { |value| where("date_start <= ?", value)}
  scope :date_end,   lambda { |value| where("date_end   => ?", value)}
  scope :user,       lambda { |value| where(:ubiquo_user_id => value)}

  filtered_search_scopes :enable => [:controller, :action, :status, :date_start, :date_end, :user]

end
