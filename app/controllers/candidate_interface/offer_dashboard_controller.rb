module CandidateInterface
  class OfferDashboardController < CandidateInterfaceController
    before_action :redirect_to_completed_dashboard_if_not_accepted_deferred_or_recruited
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    before_action :set_reference, :redirect_to_review_if_application_not_requested_yet, only: %i[view_reference]

    def show
      @application_form = current_application
      choices = current_application.application_choices.includes(:offer, course_option: [course: :provider])
      @application_choice = choices.pending_conditions.first || choices.recruited.first || choices.offer_deferred.first
      @provider_name = @application_choice.current_provider.name
      @course_name_and_code = @application_choice.current_course.name_and_code
    end

  private

    def redirect_to_review_if_application_not_requested_yet
      redirect_to candidate_interface_references_request_reference_review_path(@reference) if @reference.not_requested_yet?
    end

    def set_reference
      @reference ||= current_application.application_references.find(params[:id])
    end
  end
end
