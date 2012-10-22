module Ubiquo
  module Extensions
    module Controller

      # This method is used for 'Save and continue' button to redirect to the 
      # edit form if this button is clicked
      def check_redirects(object, continue_params = {})
        return false if request.format.js?
        
        if params[:save_and_continue] && !object.errors.present?
          redirect_to continue_params.merge(:action => 'edit', :id => object.id)
          return true
        end
        
        return false
      end

    end
  end
end