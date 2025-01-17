require 'rails_helper'

RSpec.describe DeclineOrWithdrawApplication do
  describe '#save!' do
    let(:user) { create(:provider_user, :with_make_decisions, providers: [provider]) }
    let(:provider) { application_choice.course_option.provider }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

    context 'when declining an application under offer' do
      let(:application_choice) { create(:application_choice, :offered) }

      it 'returns true' do
        expect(described_class.new(application_choice:, actor: user).save!).to be true

        expect(application_choice.reload.declined_at).not_to be_nil
        expect(application_choice).to be_declined
        expect(application_choice).not_to be_withdrawn
        expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be true
      end
    end

    context 'when withdrawing a withdrawable application' do
      it 'returns true' do
        expect(described_class.new(application_choice:, actor: user).save!).to be true

        expect(application_choice.reload.withdrawn_at).not_to be_nil
        expect(application_choice).to be_withdrawn
        expect(application_choice).not_to be_declined
        expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be true
      end
    end

    context 'when the application is not withdrawable' do
      let(:application_choice) { create(:application_choice, :withdrawn) }

      it 'raises a Workflow::NoTransitionAllowed error' do
        expect { described_class.new(application_choice:, actor: user).save! }
          .to raise_error(Workflow::NoTransitionAllowed)
      end
    end

    context 'when the provider user cannot make decisions' do
      let(:user) { create(:provider_user, providers: [provider]) }

      it 'raises a ProviderAuthorisation::NotAuthorisedError' do
        expect {
          described_class.new(application_choice:, actor: user).save!
        }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
      end
    end

    context 'when an application is withdrawn' do
      it 'an email is send to the candidate' do
        email_service_class = ProviderInterface::SendCandidateWithdrawnOnRequestEmail
        email_service = instance_double(email_service_class, call: true)

        allow(email_service_class).to receive(:new).and_return(email_service)

        described_class.new(application_choice:, actor: user).save!

        expect(email_service_class).to have_received(:new).with(application_choice:)
        expect(email_service).to have_received(:call)
      end

      it 'the CancelUpcomingInterviewsService is called' do
        cancel_service = instance_double(CancelUpcomingInterviews, call!: true)

        allow(CancelUpcomingInterviews).to receive(:new)
          .with(
            actor: user,
            application_choice:,
            cancellation_reason: 'You withdrew your application.',
          )
          .and_return(cancel_service)

        described_class.new(application_choice:, actor: user).save!

        expect(cancel_service).to have_received(:call!)
      end

      context 'CancelOutstandingReferences service' do
        let(:cancel_service) { instance_double(CancelOutstandingReferences, call!: true) }
        let(:application_form) { application_choice.application_form }

        before do
          allow(CancelOutstandingReferences)
          .to receive(:new)
          .with(
            application_form:,
          )
          .and_return(cancel_service)
        end

        it 'is called when all applications have ended without success' do
          unsuccessful_application_choices = [create(:application_choice, :rejected), create(:application_choice, :rejected), application_choice]
          application_form.application_choices << unsuccessful_application_choices

          described_class.new(application_choice:, actor: user).save!

          expect(cancel_service).to have_received(:call!)
        end

        it 'is not called when there are applications that have not ended without success' do
          application_choices_with_accepted_offer = [create(:application_choice, status: 'pending_conditions'), create(:application_choice, status: 'withdrawn'), application_choice]
          application_form.application_choices << application_choices_with_accepted_offer

          described_class.new(application_choice:, actor: user).save!

          expect(cancel_service).not_to have_received(:call!)
        end
      end
    end
  end
end
