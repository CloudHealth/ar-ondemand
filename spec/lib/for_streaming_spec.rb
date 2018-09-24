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
          AuditRecord.select([:id, :customer_id]).where(customer_id: 1).for_streaming.each do |r|
            expect(r).to be_an_instance_of(AuditRecord)
            expect(r.customer_id).to eq(1)
            expect { r.model_type_id }.to raise_error(::ActiveModel::MissingAttributeError)
            total += 1
          end
          expect(total).to be 25
        end

        it 'should allow reading computed fields' do
          AuditRecord.where(customer_id: 1).select(:id).select("id as id_computed, action as action_computed").for_streaming.each do |r|
            expect(r.action_computed).to eq('create')
            expect(r.action_computed).to be_an_instance_of(String)
            expect(r.id_computed).to be_an_instance_of(Fixnum)
          end
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

        it 'should allow reading computed fields' do
          AuditRecord.where(customer_id: 1).select(:id).select("id as id_computed, action as action_computed, DATE(created_at)").for_streaming(for_reading: true).each do |r|
            expect(r.action_computed).to eq('create')
            expect(r.action_computed).to be_an_instance_of(String)
            expect(r.id_computed).to be_an_instance_of(Fixnum)

            # no date typecasting, but we have a String
            expect(r["DATE(created_at)"]).to be_an_instance_of(String)
            expect(r["DATE(created_at)"]).to eq(Date.today.to_s)
          end
        end
      end

    end
  end
end
