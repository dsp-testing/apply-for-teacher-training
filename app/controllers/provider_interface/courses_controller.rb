module ProviderInterface
  class CoursesController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :redirect_to_application_page_unless_feature_flag_is_active

    def edit
      redirect_to provider_interface_application_choice_course_path(@application_choice)
    end

    def update
      @wizard = CourseWizard.new(change_course_store)
      if @wizard.valid?(:save)
        begin
          ChangeCourse.new(actor: current_provider_user,
                           application_choice: @application_choice,
                           course_option: @wizard.course_option).save!
          @wizard.clear_state!
          flash[:success] = t('.success')
        rescue IdenticalCourseError
          @wizard.clear_state!
          flash[:warning] = t('.failure')
        rescue ExistingCourseError
          flash[:warning] = t('.failure')
        end
      else
        @wizard.clear_state!
        track_validation_error(@wizard)

        flash[:warning] = t('.failure')
      end
      redirect_to provider_interface_application_choice_offer_path(@application_choice)
    end

  private

    def change_course_store
      key = "change_course_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def action
      'back' if !!params[:back]
    end

    def available_providers
      query_service.available_providers
    end

    def available_courses(provider_id)
      query_service.available_courses(provider: Provider.find(provider_id))
    end

    def available_course_options(course_id, study_mode)
      query_service.available_course_options(course: Course.find(course_id), study_mode: study_mode)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: current_provider_user,
        current_course: @application_choice.current_course,
      )
    end

    def redirect_to_application_page_unless_feature_flag_is_active
      redirect_to provider_interface_application_choice_path(@application_choice) unless FeatureFlag.active?(:change_course_details_before_offer)
    end
  end
end
