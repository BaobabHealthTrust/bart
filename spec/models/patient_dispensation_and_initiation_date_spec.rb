require File.dirname(__FILE__) + '/../spec_helper'

describe PatientDispensationAndInitiationDate do
  fixtures :patient, :encounter, :encounter_type, :drug, :drug_ingredient, :drug_order, 
    :orders, :order_type, :concept, :concept_class, :concept_set, :obs

  # If this fails then you need to migrate the views into your test database
  it "should have the view" do
    PatientDispensationAndInitiationDate.find(:all).should_not be_empty
  end
  
  it "should include all first line regimen dispensations"
  it "should not include non first line regimen dispensations"
  it "should include date of art initiation observations"
  it "should refer to a patient"
  # worry about voids  
end