require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleprivilegeController do 
  fixtures :patient, :encounter, :concept, :location, :users,:role_privilege,
  :concept_datatype, :concept_class, :order_type, :concept_set,:role, :privilege

  before(:each) do
    login_current_user  
    @patient = patient(:andreas)
    session[:patient_id] = @patient.id
    session[:encounter_datetime] = Time.now()
  end  
  
  it "should create a new privileges" do
    get :new
    response.should be_success
  end 
 
  it "should create aprivillege" do
    post :create ,:privilege =>{"privilege"=>privilege(:privilege_00078).privilege},:role =>{"role"=>role(:role_00005).role}
    flash[:notice].should be_eql("Role Privilege Added")
    response.should be_success
  end

  it "should list privileges" do
    get :list
    response.should be_success
  end 
 
  it "should show privileges" do
    get :show, :id => role_privilege(:role_privilege_00001).id
    response.should be_success
  end 
 
  it "should edit a privileges" do
    post :edit, :id => role_privilege(:role_privilege_00001).role_id
    response.should be_success
  end 
 
end
