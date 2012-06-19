class ActivityInfo < ActiveRecord::Base

  belongs_to :related_object, :polymorphic => true
  belongs_to :ubiquo_user

  validates :controller, :presence => true
  validates :action, :presence => true
  validates :status, :presence => true
  validates :ubiquo_user_id, :presence => true

  scope :controller,  lambda { |value| where(:controller => value)}
  scope :action,      lambda { |value| where(:action => value)}
  scope :status,      lambda { |value| where(:status => value)}
  scope :date_start,  lambda { |value| where("created_at >= ?", value)}
  scope :date_end,    lambda { |value| where("created_at <= ?", value)}
  scope :user,        lambda { |value| where(:ubiquo_user_id => value)}
  scope :users_info,  select("ubiquo_user_id, surname || ', ' || name as full_name").joins(:ubiquo_user).group(:ubiquo_user_id)

  filtered_search_scopes :enable => [:controller, :action, :status, :date_start, :date_end, :user]

  def related_object
    if related_object_type && related_object_id
      super || recover_object
    end
  end

  def related_object_name
    related_object.class.name.underscore.to_sym if related_object
  end

  def request_params
    @request_params ||= parsed_info[:request_params]
  end

  protected

  def parsed_info
    return info if info.kind_of?(Hash)
    YAML.load(info).with_indifferent_access
  end

  def recover_object
    nil
  end
end


