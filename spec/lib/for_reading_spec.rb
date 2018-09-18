require 'spec_helper'
require 'ar-ondemand'

describe 'ForReading' do
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
        AuditRecord.where(customer_id: 1).for_reading.each do |r|
          total += 1
        end
        expect(total).to be 25
      end

      it 'should support iterating' do
        total = 0
        AuditRecord.for_reading.each do |r|
          total += 1
        end
        expect(total).to be 25
      end

      it 'should produce same results as regular iterating' do
        records_a = Set.new
        AuditRecord.where(customer_id: 1).for_reading.each do |r|
          records_a.add r.id
        end

        records_b = Set.new
        AuditRecord.where(customer_id: 1).each do |r|
          records_b.add r.id
        end

        expect(records_a).to eq records_b
      end

      it 'should convert date/time fields properly' do
        AuditRecord.for_reading.each do |r|
          expect(r.created_at.class).to be Time
        end
      end

      it 'should allow reading computed fields' do
        AuditRecord.where(customer_id: 1).select("id as id_computed, action as action_computed").for_reading.each do |r|
          expect(r.action_computed).to eq('create')
          expect(r.action_computed).to be_an_instance_of(String)
          expect(r.id_computed).to be_an_instance_of(Fixnum)
        end
      end
    end
  end
end
