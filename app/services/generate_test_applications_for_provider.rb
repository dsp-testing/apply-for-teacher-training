class GenerateTestApplicationsForProvider
  def initialize(
    provider:,
    courses_per_application:,
    count:,
    for_training_courses: false,
    for_ratified_courses: false,
    for_test_provider_courses: false,
    previous_cycle: false,
    incomplete_references: false,
    next_cycle: false
  )
    @provider = provider
    @courses_per_application = courses_per_application
    @application_count = count

    if [for_training_courses, for_ratified_courses, for_test_provider_courses].none?
      for_training_courses = true
    end
    @for_training_courses = for_training_courses
    @for_ratified_courses = for_ratified_courses
    @for_test_provider_courses = for_test_provider_courses
    @previous_cycle = previous_cycle
    @incomplete_references = incomplete_references
    @next_cycle = next_cycle
  end

  def call
    raise 'This is not meant to be run in production' if HostingEnvironment.production?
    raise ParameterInvalid, 'Parameter is invalid (cannot be zero): courses_per_application' if courses_per_application.zero?

    application_count.times do
      course_ids = random_course_ids_to_apply_for

      raise ParameterInvalid, 'Parameter is invalid (cannot be greater than number of available courses): courses_per_application' if course_ids.count < courses_per_application

      GenerateTestApplicationsForCourses.perform_async(
        course_ids, courses_per_application, previous_cycle, incomplete_references, next_cycle
      )
    end
  end

private

  attr_reader :provider, :courses_per_application, :application_count, :for_training_courses,
              :for_ratified_courses, :for_test_provider_courses, :previous_cycle, :incomplete_references,
              :next_cycle

  def random_course_ids_to_apply_for
    even_split = even_split_for_number_of_course_types

    courses = []

    if for_training_courses
      courses += courses_run_by_provider.sample(even_split.pop)
    end
    if for_ratified_courses
      courses += courses_ratified_by_provider.sample(even_split.pop)
    end
    if for_test_provider_courses
      courses += courses_run_by_test_provider.sample(even_split.pop)
    end

    courses.pluck(:id)
  end

  def even_split_for_number_of_course_types
    course_types_count = [for_training_courses, for_ratified_courses, for_test_provider_courses].count(true)

    3.times.to_a.in_groups(course_types_count, false).map(&:count).shuffle
  end

  def courses_ratified_by_provider
    @_courses_ratified_by_provider ||= GetCoursesRatifiedByProvider.call(provider:, previous_cycle:)
  end

  def courses_run_by_provider
    @_courses_run_by_provider ||= if previous_cycle
                                    Course.previous_cycle.with_course_options_run_by_provider(provider)
                                  else
                                    Course.current_cycle.open_on_apply.with_course_options_run_by_provider(provider)
                                  end
  end

  def courses_run_by_test_provider
    @_courses_run_by_test_provider ||= TestProvider.training_courses(previous_cycle)
  end
end
