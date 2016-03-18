require 'spec_helper'
require 'ar-ondemand'

describe 'DeleteAllByPk' do
  context 'Testing' do
    context 'ClassMethod' do
      before(:each) do
        create(:audit_record)
      end

      it 'should delete record' do
        AuditRecord.delete_all_by_pk.should eq(1)
      end
    end

    context 'Relation' do
      before(:each) do
        create(:audit_record)
      end

      it 'should delete record' do
        AuditRecord.where('id > 0').delete_all_by_pk.should eq(1)
      end
    end
  end
end