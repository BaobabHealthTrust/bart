class ValidationRule < ActiveRecord::Base

  def self.data_consistency_checks(date = Date.today)

  end

  def self.create_update_validation_result(rule, date, result)

  end

  def self.validate_presence_of_start_reason
    #This function checks for patients who do not have a reason for starting ART

    start_reason_id = PersonAttributeType.find_by_name("Reason antiretrovirals started").id
    art_patients = Patient.find_by_sql("SELECT patient_id FROM patient_registration_dates where patient_id not in
                      (SELECT person_id from person_attribute where person_attribute_type_id = #{start_reason_id} and voided = 0)")

    return art_patients
  end

  def self.death_date_less_than_last_encounter_date_and_less_than_date_of_birth(end_date = Date.today)
    PatientProgram.find_by_sql("SELECT DISTINCT(prd.patient_id)
																FROM patient_registration_dates prd
																INNER JOIN patient p 
																ON p.patient_id = prd.patient_id
																WHERE p.birthdate IS NOT NULL 
																AND p.death_date IS NOT NULL 
																AND p.death_date < (SELECT MAX(encounter_datetime)
                       															 FROM encounter e 
                       															 WHERE e.patient_id = prd.patient_id) 
                                AND (SELECT MAX(encounter_datetime)
                       							 FROM encounter e 
                       							 WHERE e.patient_id = prd.patient_id) < p.birthdate;").length
    
  end 
end
