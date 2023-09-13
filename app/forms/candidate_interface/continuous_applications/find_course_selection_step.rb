module CandidateInterface
  module ContinuousApplications
    class FindCourseSelectionStep < DfE::WizardStep
      include Concerns::CourseSelectionStepHelper
      attr_accessor :course_id, :confirm
      validates :course_id, :confirm, presence: true

      delegate :find_url, :provider, :name_and_code, to: :course, prefix: true
      delegate :provider_id, to: :course

      def self.permitted_params
        %i[course_id confirm]
      end

      def completed?
        confirm_answer.present? && super
      end

      def exit_path
        url_helpers.candidate_interface_continuous_applications_choices_path
      end

      def next_step
        return :exit if confirm_answer.blank?

        return :course_review if completed?

        if multiple_study_modes?
          :course_study_mode
        elsif multiple_sites?
          :course_site
        end
      end

      def next_step_path_arguments
        if completed?
          { application_choice_id: application_choice.id }
        elsif multiple_study_modes?
          { provider_id:, course_id: }
        elsif multiple_sites?
          { provider_id:, course_id:, study_mode: }
        end
      end

      def study_mode
        course.available_study_modes_with_vacancies.first
      end

      def course
        Course.find(course_id)
      end

      def confirm_answer
        ActiveModel::Type::Boolean.new.cast(confirm)
      end
    end
  end
end
