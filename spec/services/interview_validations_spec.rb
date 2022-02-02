require 'rails_helper'

RSpec.describe InterviewValidations do
  subject(:interview_validations) { described_class.new(interview: interview) }

  let(:interview) { application_choice.interviews.first }
  let(:application_choice) { create(:application_choice, :with_scheduled_interview, course_option: course_option) }
  let(:course) { create(:course, :with_accredited_provider) }
  let(:provider) { course.provider }
  let(:course_option) { create(:course_option, course: course) }

  context 'existing interview with no changes' do
    let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

    it 'is valid even if date_and_time in the past' do
      expect(interview_validations).to be_valid
    end
  end

  context 'application_choice past interviewing stage' do
    let(:application_choice) { create(:application_choice, :with_offer, course_option: course_option) }

    context 'if there are no changes to be made' do
      let(:interview) { create(:interview, application_choice: application_choice) }

      it 'is still valid' do
        expect(interview_validations).to be_valid
      end
    end

    context 'new interview' do
      let(:interview) { build(:interview, application_choice: application_choice, skip_application_choice_status_update: true) }

      it 'is not valid' do
        expect(interview_validations).not_to be_valid
      end
    end

    context 'interview update' do
      let(:interview) { create(:interview, application_choice: application_choice, skip_application_choice_status_update: true) }

      it 'is not valid' do
        interview.additional_details = 'New additional details'

        expect(interview_validations).not_to be_valid
      end
    end

    context 'interview cancellation' do
      let(:interview) { create(:interview, application_choice: application_choice, skip_application_choice_status_update: true) }

      it 'makes interview cancellations not valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect(interview_validations).not_to be_valid
      end
    end
  end

  context 'new interview' do
    let(:interview) do
      build(
        :interview,
        application_choice: application_choice,
        date_and_time: nil,
      )
    end

    it 'needs a date_and_time' do
      expect(interview_validations).not_to be_valid
    end

    it 'needs an application_choice' do
      interview.application_choice = nil

      expect(interview_validations).not_to be_valid
    end

    it 'needs a provider' do
      interview.date_and_time = 3.days.from_now
      interview.provider = nil

      expect(interview_validations).not_to be_valid
    end

    it 'needs an appropriate provider' do
      interview.date_and_time = 3.days.from_now

      interview.provider = course.accredited_provider
      expect(interview_validations).to be_valid

      interview.provider = create(:provider)
      expect(interview_validations).not_to be_valid
    end

    it 'needs a location' do
      interview.location = nil

      expect(interview_validations).not_to be_valid
    end

    it 'with a date_and_time in the past is not valid' do
      interview.date_and_time = 3.days.ago

      expect(interview_validations).not_to be_valid
    end

    it 'with a date_and_time in the future is valid' do
      interview.date_and_time = 3.days.from_now

      expect(interview_validations).to be_valid
    end

    it 'with a date_and_time past the RBD date is not valid' do
      rbd_date = application_choice.reject_by_default_at
      interview.date_and_time = rbd_date + 1.second

      expect(interview_validations).not_to be_valid
    end
  end

  context 'update interview' do
    context 'any change to an interview that has passed' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

      it 'is not valid' do
        interview.additional_details = 'Changed value'

        expect(interview_validations).not_to be_valid
      end
    end

    context 'setting required fields to nil' do
      context 'setting provider to nil' do
        it 'is not valid' do
          interview.provider = nil

          expect(interview_validations).not_to be_valid
        end
      end

      context 'setting location to nil' do
        it 'is not valid' do
          interview.location = nil

          expect(interview_validations).not_to be_valid
        end
      end

      context 'setting location to > 2000 words' do
        it 'is not valid' do
          interview.location = 'A ' * 2001

          expect(interview_validations).not_to be_valid
        end
      end

      context 'setting additional_details to nil' do
        it 'is valid' do
          interview.additional_details = nil

          expect(interview_validations).to be_valid
        end
      end

      context 'setting additional_details to > 2000 words' do
        it 'is not valid' do
          interview.additional_details = 'A ' * 2001

          expect(interview_validations).not_to be_valid
        end
      end
    end

    context 'provider' do
      context 'becomes the training provider' do
        let(:provider) { course.accredited_provider }

        it 'is valid' do
          interview.provider = course.provider

          expect(interview_validations).to be_valid
        end
      end

      context 'becomes the ratifying provider' do
        it 'is valid' do
          interview.provider = course.accredited_provider

          expect(interview_validations).to be_valid
        end
      end

      context 'becomes any other provider' do
        it 'is not valid' do
          interview.provider = create(:provider)

          expect(interview_validations).not_to be_valid
        end
      end
    end

    context 'date_and_time' do
      context 'changes from future to past' do
        it 'is not valid' do
          interview.date_and_time = 5.days.ago

          expect(interview_validations).not_to be_valid
        end
      end

      context 'changes from past to future' do
        let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

        it 'is not valid' do
          interview.date_and_time = 2.days.from_now

          expect(interview_validations).not_to be_valid
        end
      end

      context 'changes from past to past' do
        let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

        it 'is not valid' do
          interview.date_and_time -= 1.day

          expect(interview_validations).not_to be_valid
        end
      end

      context 'changes from future to future' do
        it 'is valid' do
          interview.date_and_time += 1.day

          expect(interview_validations).to be_valid
        end
      end

      context 'changes from future to after RBD date' do
        it 'is not valid' do
          rbd_date = application_choice.reject_by_default_at
          interview.date_and_time = rbd_date + 1.second

          expect(interview_validations).not_to be_valid
        end
      end
    end
  end

  context 'cancel interview' do
    context 'without a cancellation reason' do
      it 'is not valid' do
        interview.cancelled_at = Time.zone.now

        expect(interview_validations).not_to be_valid
      end
    end

    context 'with a cancellation reason > 2000 words' do
      it 'is not valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A ' * 2001

        expect(interview_validations).not_to be_valid
      end
    end

    context 'when interview is in the future' do
      it 'is valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect(interview_validations).to be_valid
      end
    end

    context 'when interview has passed' do
      let(:interview) { create(:interview, :past_date_and_time, application_choice: application_choice) }

      it 'is not valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect(interview_validations).not_to be_valid
      end
    end

    context 'when interview is already cancelled' do
      let(:interview) { create(:interview, :cancelled, date_and_time: 5.days.from_now) }

      it 'is not valid' do
        interview.cancelled_at = Time.zone.now
        interview.cancellation_reason = 'A cancellation reason'

        expect(interview_validations).not_to be_valid
      end
    end
  end
end
