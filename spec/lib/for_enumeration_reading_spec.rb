require 'spec_helper'
require 'ar-ondemand'

describe 'ForEnumerationReading' do
  context 'Testing' do
    context 'Ensure Persistance Works' do
      before(:each) do
        create(:audit_record)
      end

      it 'should do persist' do
        expect(AuditRecord.all.length).to be 1
      end

      it 'should do foo' do
        expect(AuditRecord.first.action).to eq 'create'
      end
    end

    context 'Iterating' do
      before(:each) do
        (1..25).each do
          create(:audit_record)
        end
      end

      it 'should support iterating' do
        total = 0
        AuditRecord.where(customer_id: 1).for_enumeration_reading.each do |r|
          total += 1
        end
        expect(total).to be 25
      end

      it 'should support inject iterating' do
        inj = AuditRecord.where(customer_id: 1).for_enumeration_reading.inject([]) do |i,r|
          i << r.id
        end
        expect(inj.size).to be 25
      end

      it 'should produce same results as regular iterating' do
        records_a = Set.new
        AuditRecord.where(customer_id: 1).for_enumeration_reading.each do |r|
          records_a.add r.id
        end

        records_b = Set.new
        AuditRecord.where(customer_id: 1).each do |r|
          records_b.add r.id
        end

        expect(records_a).to eq records_b
      end

      it 'should not allow access outside each enumeration' do
        obj = nil
        AuditRecord.where(customer_id: 1).for_enumeration_reading.each do |r|
          obj = r
        end
        expect{obj.id}.to raise_error(RuntimeError)
      end

      it 'should not allow access outside each inject enumeration' do
        cache = AuditRecord.where(customer_id: 1).for_enumeration_reading.inject({}) do |h,r|
          h[r.id] = r
          h
        end
        expect{cache.first[1].id}.to raise_error(RuntimeError)
      end

      it 'should  return the correct size' do
        expect(AuditRecord.where(customer_id: 1).for_enumeration_reading.size).to be 25
      end

      it 'should  return the correct size' do
        expect(AuditRecord.where(customer_id: 1).for_enumeration_reading.size).to be 25
      end

      it 'batch option should return enumerator' do
        expect(AuditRecord.where(customer_id: 1).for_enumeration_reading(batch_size: 1).class).to be ::Enumerator
      end

      it 'no batch option should return fastiteration' do
        expect(AuditRecord.where(customer_id: 1).for_enumeration_reading.class).to be ::ActiveRecord::OnDemand::FastEnumeration
      end

    end
  end
end
