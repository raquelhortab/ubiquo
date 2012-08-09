# This file adds the tasks that are useful to all ubiquo gems

def detect_calling_ubiquo_gem
  caller_file = caller[1].sub(/:\d+.*/, '')
  File.basename(File.dirname(caller_file))
end

ENV['UGEM'] = detect_calling_ubiquo_gem
Dir.glob(File.dirname(__FILE__) + "/../gem_tasks/*.rake").each {|f| import f}