module CandidateInterface
  module CourseChoices
    class CourseDecisionController < BaseController
      include AdviserStatus

      def ask
        set_backlink
        @choice_form = CandidateInterface::CourseChosenForm.new
      end

      def decide
        @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
        set_backlink
        render :ask and return unless @choice_form.valid?

        if @choice_form.chosen_a_course?
          redirect_to candidate_interface_course_choices_provider_path
        else
          redirect_to candidate_interface_go_to_find_path
        end
      end

      def go_to_find; end

    private

      def application_choice_params
        params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
      end

      def set_backlink
        @backlink = if current_application.application_choices.any?
                      candidate_interface_course_choices_review_path
                    else
                      candidate_interface_application_form_path
                    end
      end
    end
  end
end
