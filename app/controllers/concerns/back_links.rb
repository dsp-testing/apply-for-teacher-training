# Helper methods relating to backlinks
#
module BackLinks
  extend ActiveSupport::Concern

  def return_to_after_edit(default:)
    if redirect_back_to_application_review_page?
      { back_path: candidate_interface_application_review_path, params: redirect_back_to_application_review_page_params }
    else
      { back_path: default, params: {} }
    end
  end

  def redirect_back_to_application_review_page_params
    { 'return-to' => 'application-review' }
  end

  def redirect_back_to_application_review_page?
    params['return-to'] == 'application-review' || params[:return_to] == 'application-review'
  end

  # Method to determine the path to the candidates current dashboard based on
  # contextual information.
  def application_form_path
    # `current_application` is a `helper_method` defined in CandidateInterfaceController
    # It's not available in view specs
    return '' unless defined?(current_application)

    if current_application.continuous_applications?
      continuous_application_form_path
    else
      old_cycle_application_form_path
    end
  end
  module_function :application_form_path

  def continuous_application_form_path
    if request.path.match?(/withdraw/)
      candidate_interface_continuous_applications_choices_path
    else
      candidate_interface_continuous_applications_details_path
    end
  end

  def old_cycle_application_form_path
    if current_application.submitted?
      candidate_interface_application_review_submitted_path
    else
      candidate_interface_application_form_path
    end
  end

  included do
    helper_method :application_form_path
  end
end
