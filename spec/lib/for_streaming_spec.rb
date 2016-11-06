require 'spec_helper'
require 'ar-ondemand'

describe 'ForStreaming' do
  context 'Testing' do
    context 'Iterating' do
      before(:each) do
        (1..25).each do
          create(:audit_record)
        end
      end

      context 'AR' do
        it 'ClassMethod should support streaming' do
          total = 0
          AuditRecord.for_streaming.each do |r|
            expect(r).to be_an_instance_of(AuditRecord)
            total += 1
          end
          expect(total).to be 25
        end

        it 'Relation should support streaming' do
          total = 0
          AuditRecord.where(customer_id: 1).for_streaming.each do |r|
            expect(r).to be_an_instance_of(AuditRecord)
            total += 1
          end
          expect(total).to be 25
        end

        it 'should support select' do
          total = 0
          AuditRecord.select([:customer_id]).where(customer_id: 1).for_streaming.each do |r|
            expect(r).to be_an_instance_of(AuditRecord)
            expect(r.customer_id).to eq(1)
            expect { r.model_type_id }.to raise_error(::ActiveModel::MissingAttributeError)
            total += 1
          end
          expect(total).to be 25
        end
      end

      context 'For Reading' do
        it 'ClassMethod should support streaming' do
          total = 0
          AuditRecord.for_streaming(for_reading: true).each do |r|
            expect(r).not_to be_an_instance_of(AuditRecord)
            expect(r.customer_id).to be 1
            total += 1
          end
          expect(total).to be 25
        end

        it 'Relation should support streaming' do
          total = 0
          AuditRecord.where(customer_id: 1).for_streaming(for_reading: true).each do |r|
            expect(r).not_to be_an_instance_of(AuditRecord)
            expect(r.customer_id).to be 1
            total += 1
          end
          expect(total).to be 25
        end
      end

    end
  end
end
