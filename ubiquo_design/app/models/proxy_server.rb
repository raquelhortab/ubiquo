class ProxyServer < ActiveRecord::Base
  attr_accessible :host, :port

  validates_presence_of :host
  validates_presence_of :port

  DEAD_MINUTES = 5

  scope :alive, lambda{
    where(:updated_at => (DEAD_MINUTES.minutes.ago .. 0.minutes.ago))
  }

  scope :obsolete, lambda{
    where("updated_at < ?", DEAD_MINUTES.minutes.ago)
  }

  # Exception raised when the remote server cannot be found.
  class RemoteProxyServerNotFound < RuntimeError; end;

  def self.delete_all_obsolete
    self.obsolete.delete_all
  end

  def self.find_or_initialize(host, port)
    find_by_host_and_port(host, port) || new(:host => host, :port => port)
  end

end
