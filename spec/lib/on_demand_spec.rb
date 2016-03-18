require 'spec_helper'
require 'ar-ondemand'

describe 'OnDemand' do
  before(:each) do
    (1..25).each do
      create(:widget)
    end
  end

  context 'Existing' do
    it 'should get asset' do
      assets = ::Widget.where(customer_id: 1).on_demand :identifier, customer_id: 1
      ids = assets.ids
      expect(ids.length).to eql(25)

      x = assets['w-1']
      expect(x.identifier).to eql('w-1')
      expect(x.id).to eql(1)
      expect(x).to be_an_instance_of(::ActiveRecord::OnDemand::Record)
    end
  end

  context 'Update Existing' do
    it 'saving should get instance of a Widget' do
      assets = ::Widget.where(customer_id: 1).on_demand :identifier, customer_id: 1
      x = assets['w-26']
      expect(x.identifier).to eql('w-26')
      expect(x).to be_an_instance_of(::ActiveRecord::OnDemand::Record)

      x.customer_id = 2
      obj = x.save
      expect(obj).to be_an_instance_of(::Widget)
    end
  end

  context 'Create' do
    it 'should create asset' do
      assets = ::Widget.where(customer_id: 1).on_demand :identifier, customer_id: 1
      x = assets['w-999']
      expect(x.identifier).to eql('w-999')
      expect(x.id).to eql(nil)
      expect(x.persisted?).to eql(false)
      expect(x).to be_an_instance_of(::Widget)
    end
  end
end
