class ReapplyValidator < ActiveModel::Validator
  def validate(record)
    return if record_has_reapply_status?(record)
    return if blank_attributes?(record)

    scope = record.application_form.application_choices.joins(:course_option)

    scope = restrict_to_reapply_statuses(scope)

    scope = omit_current_application_choice(scope, record) if updating?(record)

    exists = scope.exists?(course_option: { course_id: record.course_option.course_id })

    if exists
      record.errors.add :base, 'cannot apply to the same course when an open application exists'
    end
  end

  def updating?(record)
    record.persisted?
  end

  def omit_current_application_choice(scope, record)
    scope.where.not({ id: record.id })
  end

  def restrict_to_reapply_statuses(scope)
    scope.where({ status: ApplicationStateChange::NON_REAPPLY_STATUSES })
  end

  def record_has_reapply_status?(record)
    ApplicationStateChange::REAPPLY_STATUSES.include?(record.status.to_s.to_sym)
  end

  def blank_attributes?(record)
    record.application_form_id.blank? || record.course_option_id.blank?
  end
end
