# An email is sent to the candidate at 7 days, 14 days and 28 days
# An email is sent to the referee at 7 days, 21 days and 28 days

class ChaseReferences
  include Sidekiq::Worker

  def perform
    send_7_day_chaser!
    send_14_day_chaser!
    send_21_day_chaser!
    send_28_day_chaser!
  end

private

  def send_7_day_chaser!
    references = ApplicationReference
      .joins(:application_form)
      .feedback_requested
      .where(application_forms: { recruitment_cycle_year: ApplicationForm.select('candidate_id').maximum(:recruitment_cycle_year) })
      .where(['requested_at < ?', TimeLimitConfig.chase_referee_by.days.before(Time.zone.now)])
      .where.not(id: ChaserSent.reference_request.select(:chased_id))

    references.each do |reference|
      RefereeMailer.reference_request_chaser_email(reference.application_form, reference).deliver_later
      CandidateMailer.chase_reference(reference).deliver_later
      ChaserSent.create!(chased: reference, chaser_type: :reference_request)
    end
  end

  def send_14_day_chaser!
    references = ApplicationReference
      .joins(:application_form)
      .feedback_requested
      .where(application_forms: { recruitment_cycle_year: ApplicationForm.select('candidate_id').maximum(:recruitment_cycle_year) })
      .where(['requested_at < ?', TimeLimitConfig.replace_referee_by.days.before(Time.zone.now)])
      .where.not(id: ChaserSent.reference_replacement.select(:chased_id))

    references.each do |reference|
      SendNewRefereeRequestEmail.call(
        reference:,
        reason: :not_responded,
      )
    end
  end

  def send_21_day_chaser!
    references = ApplicationReference
                   .joins(:application_form)
                   .feedback_requested
                   .where(application_forms: { recruitment_cycle_year: ApplicationForm.select('candidate_id').maximum(:recruitment_cycle_year) })
                   .where(['requested_at < ?', TimeLimitConfig.second_chase_referee_by.days.before(Time.zone.now)])
                   .where.not(id: ChaserSent.reminder_reference_nudge.select(:chased_id))

    references.each do |reference|
      RefereeMailer.reference_request_chaser_email(reference.application_form, reference).deliver_later
      ChaserSent.create!(chased: reference, chaser_type: :reminder_reference_nudge)
    end
  end

  def send_28_day_chaser!
    references = ApplicationReference
      .joins(:application_form)
      .feedback_requested
      .where(application_forms: { recruitment_cycle_year: ApplicationForm.select('candidate_id').maximum(:recruitment_cycle_year) })
      .where(['requested_at < ?', TimeLimitConfig.additional_reference_chase_calendar_days.days.before(Time.zone.now)])
      .where.not(id: ChaserSent.follow_up_missing_references.select(:chased_id))

    references.each do |reference|
      RefereeMailer.reference_request_chase_again_email(reference).deliver_later
      CandidateMailer.chase_reference_again(reference).deliver_later
      ChaserSent.create!(chased: reference, chaser_type: :follow_up_missing_references)
    end
  end
end
