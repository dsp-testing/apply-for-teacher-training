module CandidateInterface
  class BecomingATeacherReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @becoming_a_teacher_form = CandidateInterface::BecomingATeacherForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def becoming_a_teacher_form_rows
      [becoming_a_teacher_form_row]
    end

    def show_missing_banner?
      !@application_form.becoming_a_teacher_completed && @editable if @submitting_application
    end

    def review_needed?
      @application_form.review_pending?(:becoming_a_teacher)
    end

  private

    attr_reader :application_form

    def becoming_a_teacher_form_row
      {
        key: personal_statement_label,
        value: @becoming_a_teacher_form.becoming_a_teacher,
        action: {
          href: candidate_interface_edit_becoming_a_teacher_path(return_to_params),
          visually_hidden_text: visually_hidden_text,
        },
        html_attributes: {
          data: {
            qa: 'becoming-a-teacher',
          },
        },
      }
    end

    def personal_statement_label
      if @application_form.single_personal_statement_application?
        t('application_form.personal_statement.review.label')
      else
        t('application_form.personal_statement.becoming_a_teacher.label')
      end
    end

    def visually_hidden_text
      if @application_form.single_personal_statement_application?
        'personal statement'
      else
        t('application_form.personal_statement.becoming_a_teacher.change_action')
      end
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
