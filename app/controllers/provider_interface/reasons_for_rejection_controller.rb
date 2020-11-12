module ProviderInterface
  class ReasonsForRejectionController < ProviderInterfaceController
    before_action :ensure_structured_reasons_for_rejection_feature_is_active
    before_action :set_application_choice

    def edit_initial_questions
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'initial_questions')
      @wizard.save_state!
    end

    def update_initial_questions
      @wizard = ReasonsForRejectionWizard.new(store, reasons_for_rejection_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_initial_questions
      end
    end

    def edit_other_reasons
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'other_reasons')
      @wizard.save_state!
    end

    def update_other_reasons
      @wizard = ReasonsForRejectionWizard.new(store, reasons_for_rejection_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_other_reasons
      end
    end

    def check
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'check')
      @wizard.save_state!
    end

    def commit
      @wizard = ReasonsForRejectionWizard.new(store)
      service = RejectApplication.new(actor: current_provider_user, application_choice: @application_choice, structured_rejection_reasons: @wizard.to_model)

      if service.save
        @wizard.clear_state!

        flash[:success] = 'Application rejected'
        redirect_to provider_interface_applications_path
      else
        render :check
      end
    end

    def next_redirect(wizard)
      {
        'other_reasons' => { action: :edit_other_reasons },
        'check' => { action: :check },
      }.fetch(wizard.next_step)
    end

    def reasons_for_rejection_params
      params.require(:provider_interface_reasons_for_rejection)
        .permit(:candidate_behaviour_y_n, :candidate_behaviour_other,
                :candidate_behaviour_what_to_improve,
                :quality_of_application_y_n, :quality_of_application_personal_statement_what_to_improve,
                :quality_of_application_subject_knowledge_what_to_improve,
                :quality_of_application_other_details, :quality_of_application_other_what_to_improve,
                :qualifications_y_n, :qualifications_other_details,
                :performance_at_interview_y_n, :performance_at_interview_what_to_improve,
                :course_full_y_n,
                :offered_on_another_course_y_n,
                :offered_on_another_course_details,
                :honesty_and_professionalism_y_n,
                :honesty_and_professionalism_concerns_plagiarism_details,
                :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                :honesty_and_professionalism_concerns_references_details,
                :honesty_and_professionalism_concerns_other_details,
                :safeguarding_y_n,
                :safeguarding_concerns_candidate_disclosed_information_details,
                :safeguarding_concerns_vetting_disclosed_information_details,
                :safeguarding_concerns_other_details,
                :other_advice_or_feedback_y_n,
                :other_advice_or_feedback_details,
                :interested_in_future_applications_y_n,
                :why_are_you_rejecting_this_application,
                honesty_and_professionalism_concerns: [],
                safeguarding_concerns: [],
                qualifications_which_qualifications: [],
                quality_of_application_which_parts_needed_improvement: [],
                candidate_behaviour_what_did_the_candidate_do: [])
    end

    def store
      key = "reasons_for_rejection_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def ensure_structured_reasons_for_rejection_feature_is_active
      render_404 unless FeatureFlag.active?(:structured_reasons_for_rejection)
    end
  end
end
