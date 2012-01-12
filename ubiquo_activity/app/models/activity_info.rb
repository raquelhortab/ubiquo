class ActivityInfo < ActiveRecord::Base
  validates_presence_of :controller, :action, :status, :ubiquo_user_id
  belongs_to :related_object, :polymorphic => true
  belongs_to :ubiquo_user

  named_scope :controller, lambda {|value| {:conditions => {:controller => value}}}
  named_scope :action, lambda {|value| {:conditions => {:action => value}}}
  named_scope :status, lambda {|value| {:conditions => {:status => value}}}
  named_scope :date_start, lambda {|value| {:conditions => ["created_at >= ?", value]}}
  named_scope :date_end, lambda {|value| {:conditions => ["created_at <= ?", value]}}
  named_scope :user, lambda {|value| {:conditions => {:ubiquo_user_id => value}}}
  
filtered_search_scopes :enable => [:controller, :action, :status, :date_start, :date_end, :user]

  #For backwards compatibility
  def self.filtered_search(filters = {}, options = {})
    
    new_filters = {}
    filters.each do |key, value|
      case key
        when :controller
          new_filters["filter_controller"] = value
        when :action
          new_filters["filter_action"] = value
        when :status
          new_filters["filter_status"] = value
        when :date_start
          new_filters["filter_date_start"] = value
        when :date_end
          new_filters["filter_date_end"] = value
        when :user
          new_filters["filter_user"] = value
        else
          new_filters[key] = value
      end
    end

    super new_filters, options
  end  
end
