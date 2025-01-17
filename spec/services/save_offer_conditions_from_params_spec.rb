require 'rails_helper'

RSpec.describe SaveOfferConditionsFromParams do
  subject(:service) do
    described_class.new(application_choice:,
                        standard_conditions:,
                        further_condition_attrs:)
  end

  let(:standard_conditions) { [] }
  let(:further_condition_attrs) { {} }
  let(:application_choice) { build(:application_choice) }

  describe '#conditions' do
    let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }
    let(:further_condition_attrs) do
      {
        0 => {
          'text' => 'You must have a driving license',
        },
        1 => {
          'text' => 'Blue hair',
        },
      }
    end

    it 'returns a text array of all serialized conditions' do
      expect(service.conditions).to contain_exactly(standard_conditions.first, 'You must have a driving license', 'Blue hair')
    end
  end

  describe '#save' do
    context 'when there is no offer for the application_choice' do
      it 'create an offer when one does not exist' do
        expect { service.save }.to change(Offer, :count).by(1)
      end
    end

    context 'analytics' do
      before do
        FeatureFlag.activate(:send_request_data_to_bigquery)
      end

      it 'sends the offer creation event to dfe analytics' do
        expect do
          service.save
        end.to have_sent_analytics_event_types(:create_entity)
      end

      context 'with SKE conditions' do
        let(:offer) do
          build(:offer, :with_ske_conditions)
        end

        it 'sends the offer creation event to dfe analytics' do
          expect do
            service.save
          end.to have_sent_analytics_event_types(:create_entity)
        end
      end

      context 'when there are multiple conditions' do
        ske_condition = OfferCondition.new(type: 'SkeCondition', status: 'pending')
        reference_condition = OfferCondition.new(type: 'ReferenceCondition', status: 'pending', details: { required: true, description: 'where is my reference' })
        text_condition = OfferCondition.new(type: 'TextCondition', status: 'pending', details: { description: 'test' })
        let(:offer) { create(:offer, conditions: [reference_condition, ske_condition, text_condition]) }

        let(:application_choice) { offer.application_choice }

        it 'sends the offer creation events to DfE Analytics' do
          service.save

          offer_condition_jobs = enqueued_jobs.select { |job| job['arguments'][0][0]['entity_table_name'] == 'offer_conditions' }

          condition_types = %w[ReferenceCondition SkeCondition TextCondition]

          condition_types.each do |type|
            count = offer_condition_jobs.count do |job|
              job['arguments'][0][0]['data'][2]['value'][0] == type
            end

            expect(count).to eq 2
          end
        end
      end
    end

    context 'when there is an existing offer for the application_choice' do
      let!(:application_choice) { create(:application_choice, :offered) }

      it 'create an offer when one does not exist' do
        expect { service.save }.not_to change(Offer, :count)
      end
    end

    context 'when we have standard and further conditions' do
      context 'when we make changes to further conditions' do
        let!(:application_choice) { create(:application_choice, :offered, offer:) }
        let(:offer) do
          build(:offer, conditions: [build(:text_condition, description: OfferCondition::STANDARD_CONDITIONS.first),
                                     build(:text_condition, description: OfferCondition::STANDARD_CONDITIONS.last),
                                     build(:text_condition, description: 'Red hair')])
        end

        let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }
        let(:further_condition_attrs) do
          {
            0 => {
              'text' => 'You must have a driving license',
            },
            1 => {
              'condition_id' => offer.conditions.last.id,
              'text' => 'Blue hair',
            },
          }
        end

        it 'returns the expected results' do
          service.save

          expect(offer.reload.conditions.map(&:text)).to contain_exactly(standard_conditions.first,
                                                                         'You must have a driving license',
                                                                         'Blue hair')
        end
      end
    end

    context 'standard_conditions' do
      let!(:application_choice) { create(:application_choice, :offered, offer:) }
      let(:standard_conditions) { [OfferCondition::STANDARD_CONDITIONS.sample] }

      context 'when they dont already exist on the offer' do
        let(:offer) { build(:unconditional_offer) }

        it 'the service creates them' do
          expect { service.save }.to change(offer.conditions, :count).by(1)
        end
      end

      context 'when they do exist on the offer' do
        let(:offer) { build(:offer, conditions: [build(:text_condition, description: standard_conditions.first)]) }

        it 'the service does nothing' do
          expect { service.save }.not_to change(offer.conditions, :count)
        end
      end

      context 'when they are removed' do
        let(:offer) { build(:offer, conditions: [build(:text_condition, description: OfferCondition::STANDARD_CONDITIONS.first)]) }
        let(:standard_conditions) { [] }

        it 'the service deletes the existing entries' do
          expect { service.save }.to change(offer.conditions, :count).by(-1)
        end
      end
    end

    context 'further_conditions' do
      let!(:application_choice) { create(:application_choice, :offered, offer:) }
      let(:further_condition_attrs) do
        {
          0 => {
            'text' => 'You must have a driving license',
          },
        }
      end

      context 'when they dont already exist on the offer' do
        let(:offer) { build(:unconditional_offer) }

        it 'the service creates them' do
          expect { service.save }.to change(offer.reload.conditions, :count).by(1)
          expect(offer.conditions.first.text).to eq('You must have a driving license')
        end
      end

      context 'when they do exist on the offer' do
        let(:offer) { build(:offer, conditions: [build(:text_condition, description: 'You must have a driving license')]) }
        let(:further_condition_attrs) do
          {
            0 => {
              'condition_id' => offer.conditions.first.id,
              'text' => 'You must have a driving license',
            },
          }
        end

        it 'the service does nothing' do
          expect { service.save }.not_to change(offer.conditions, :count)
        end
      end

      context 'when they are removed' do
        let(:offer) { build(:offer, conditions: [build(:text_condition, description: 'You must have a driving license')]) }
        let(:further_condition_attrs) { {} }

        it 'the service deletes the existing entries' do
          expect { service.save }.to change(offer.conditions, :count).by(-1)
        end
      end

      context 'when they are updated' do
        let!(:application_choice) { create(:application_choice, :offered, offer:) }
        let(:offer) { build(:offer, conditions: [build(:text_condition, description: 'You must have a driving license')]) }
        let(:further_condition_attrs) do
          {
            0 => {
              'condition_id' => offer.conditions.first.id,
              'text' => 'You must NOT have a driving license',
            },
          }
        end

        it 'the service updates the existing entries' do
          expect { service.save }
            .to not_change(offer.conditions, :count)
            .and change { offer.conditions.first.reload.text }.to('You must NOT have a driving license')
        end
      end

      context 'when a conditions with an invalid id is provided' do
        let!(:application_choice) { create(:application_choice, :offered, offer:) }
        let(:offer) { build(:unconditional_offer) }
        let(:further_condition_attrs) do
          {
            0 => {
              'conditions_id' => '',
              'text' => 'A valid new condition',
            },
            1 => {
              'condition_id' => 999,
              'text' => 'You must NOT have a driving license',
            },
          }
        end

        it 'the entire transaction is cancelled' do
          expect { service.save }.to raise_error(ValidationException)
            .and not_change(offer.conditions, :count)
        end
      end
    end

    context 'structured conditions' do
      let(:application_choice) { create(:application_choice, :offered, offer: create(:offer, :with_ske_conditions)) }

      subject(:service) do
        described_class.new(application_choice: application_choice,
                            standard_conditions: [],
                            further_condition_attrs: {},
                            support_action: true)
      end

      it 'does not remove a SKE condition' do
        expect { service.save }.to not_change(application_choice.offer.ske_conditions, :count)
      end
    end
  end
end
