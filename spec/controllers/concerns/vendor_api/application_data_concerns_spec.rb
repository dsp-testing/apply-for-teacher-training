require 'rails_helper'
RSpec.describe VendorAPI::ApplicationDataConcerns do
  subject(:application_data_concerns) { ::TestApplicationDataConcerns.new(provider, api_version: version) }

  let(:provider) { build(:provider) }

  describe '#application_choices_visible_to_provider' do
    before do
      allow(GetApplicationChoicesForProviders).to receive(:call)
    end

    context 'when version is v1' do
      let(:version) { 'v1' }

      it 'excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: true)
      end
    end

    context 'when version is v1.0' do
      let(:version) { 'v1.0' }

      it 'excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: true)
      end
    end

    context 'when version is v1.1' do
      let(:version) { 'v1.1' }

      it 'does not excludes deferrals' do
        application_data_concerns.send(:application_choices_visible_to_provider)

        expect(GetApplicationChoicesForProviders)
          .to have_received(:call).with(providers: [provider], exclude_deferrals: false)
      end
    end
  end
end

class TestApplicationDataConcerns
  include VendorAPI::ApplicationDataConcerns
  include Versioning

  attr_reader :current_provider, :params

  def initialize(provider, params)
    @current_provider = provider
    @params = params
  end
end