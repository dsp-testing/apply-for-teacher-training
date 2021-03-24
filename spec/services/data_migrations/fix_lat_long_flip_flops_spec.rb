require 'rails_helper'

RSpec.describe DataMigrations::FixLatLongFlipFlops, with_audited: true do
  it 'deletes audits that set lat/long to nil' do
    provider = create(:provider)
    expect(provider.audits.count).to eq 1

    provider.update(latitude: 1, longitude: 1)
    expect(provider.audits.count).to eq 2

    provider.update(latitude: nil, longitude: nil)
    expect(provider.audits.count).to eq 3

    described_class.new.change

    expect(provider.audits.count).to eq 2
    expect(provider.audits.last.audited_changes).to eq({ 'latitude' => [nil, 1.0], 'longitude' => [nil, 1.0] })
  end

  it 'deletes duplicated audits that set lat/long' do
    provider = FactoryBot.create(:provider)
    expect(provider.audits.count).to eq 1

    provider.update(latitude: 1, longitude: 1)
    expect(provider.audits.count).to eq 2

    provider.update(latitude: nil, longitude: nil)
    expect(provider.audits.count).to eq 3

    provider.update(latitude: 1, longitude: 1)
    expect(provider.audits.count).to eq 4

    described_class.new.change

    expect(provider.audits.count).to eq 2
    expect(provider.audits.last.audited_changes).to eq({ 'latitude' => [nil, 1.0], 'longitude' => [nil, 1.0] })
  end

  it 'does not retain an extra audit when lat/long was set at creation time' do
    provider = create(:provider, latitude: 1, longitude: 1)
    expect(provider.audits.count).to eq 1

    provider.update(latitude: nil, longitude: nil)
    expect(provider.audits.count).to eq 2

    provider.update(latitude: 1, longitude: 1)
    expect(provider.audits.count).to eq 3

    described_class.new.change

    expect(provider.audits.count).to eq 1
  end

  it 'can handle two providers with different orderings of changes' do
    p1 = create(:provider)
    p2 = create(:provider, latitude: 1, longitude: 1)

    p1.update(latitude: 1, longitude: 1)
    p1.update(latitude: nil, longitude: nil)

    p2.update(latitude: nil, longitude: nil)
    p2.update(latitude: 1, longitude: 1)

    described_class.new.change

    expect(p1.audits.count).to eq(2)
    expect(p1.audits.last.audited_changes).to eq({ 'latitude' => [nil, 1.0], 'longitude' => [nil, 1.0] })

    expect(p2.audits.count).to eq(1)
  end

  it 'logs the result' do
    provider = create(:provider)
    provider.update(latitude: 1, longitude: 1)
    provider.update(latitude: nil, longitude: nil)
    provider.update(latitude: 1, longitude: 1)

    allow(Rails.logger).to receive(:info).and_call_original

    described_class.new.change

    expect(Rails.logger).to have_received(:info).with('Deleted 2 lat/long audits out of 3')
  end
end
