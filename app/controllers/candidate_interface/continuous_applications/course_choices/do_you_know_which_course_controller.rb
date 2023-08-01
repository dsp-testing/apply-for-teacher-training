module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class DoYouKnowWhichCourseController < BaseController
      private

        def step_params
          params
        end

        def current_step
          :do_you_know_the_course
        end
      end
    end
  end
end
