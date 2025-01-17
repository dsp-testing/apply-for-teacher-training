module CandidateInterface
  module ContinuousApplications
    class CourseSelectionWizard < DfE::Wizard
      # application_choice is only used in edit and update
      attr_accessor :current_application, :application_choice

      steps do
        [
          { do_you_know_the_course: DoYouKnowTheCourseStep },
          { go_to_find_explanation: GoToFindExplanationStep },
          { provider_selection: ProviderSelectionStep },
          { which_course_are_you_applying_to: WhichCourseAreYouApplyingToStep },
          { duplicate_course_selection: DuplicateCourseSelectionStep },
          { full_course_selection: FullCourseSelectionStep },
          { course_study_mode: CourseStudyModeStep },
          { course_site: CourseSiteStep },
          { find_course_selection: FindCourseSelectionStep },
          { course_review: CourseReviewStep },
        ]
      end

      store CourseSelectionStore

      def logger
        DfE::Wizard::Logger.new(Rails.logger, if: -> { HostingEnvironment.test_environment? })
      end

      def completed?
        current_step.respond_to?(:completed?) && current_step.completed?
      end
    end
  end
end
