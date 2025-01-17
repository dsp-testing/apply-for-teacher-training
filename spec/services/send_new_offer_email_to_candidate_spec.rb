require 'rails_helper'

RSpec.describe SendNewOfferEmailToCandidate, :continuous_applications do
  describe '#call' do
    def setup_application
      @candidate = create(:candidate)
      @application_form = create(
        :application_form,
        candidate: @candidate,
      )
      course_option = create(:course_option)
      @application_choice = @application_form.application_choices.create(
        application_form: @application_form,
        original_course_option: course_option,
        course_option:,
        current_course_option: course_option,
        status: :offer,
      )
    end

    context 'when there is a single offer' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_made).and_return(mail)
        setup_application
      end

      it 'sends new offer accepted email' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_made).with(@application_choice)
      end
    end

    context 'when there are multiple offers' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_made).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :offer,
        )
      end

      it 'sends new offer accepted email' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_made).with(@application_choice)
      end
    end

    context 'when there are other choices in the awaiting_provider_decision state' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_made).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :awaiting_provider_decision,
        )
      end

      it 'sends new offer accepted email' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_made).with(@application_choice)
      end
    end

    context 'when there are other choices in the interviewing state' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_made).and_return(mail)
        setup_application
        other_course_option = create(:course_option)
        @application_form.application_choices.create(
          application_form: @application_form,
          original_course_option: other_course_option,
          course_option: other_course_option,
          current_course_option: other_course_option,
          status: :interviewing,
        )
      end

      it 'sends new offer accepted email' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_made).with(@application_choice)
      end
    end
  end
end
