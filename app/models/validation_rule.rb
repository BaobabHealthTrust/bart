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
    patient_ids = PatientProgram.find_by_sql("SELECT DISTINCT(prd.patient_id)
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
                       							 WHERE e.patient_id = prd.patient_id) < p.birthdate;").map(&:patient_id) 
     return patient_ids
    
  end

  def self.validate_newly_registered_is_sum_of_initiated_reinited_and_transferred_in(start_date = @start_date, end_date = @end_date)
    total_registered = []
    total_initiated = []
    total_reinitiated = []
    total_transferred_in = []
    
    conditions = ["registration_date >= ? AND registration_date <= ?",
                                                 @start_date, @end_date]
    conditions = ["registration_date >= ? AND registration_date <= ? AND age_at_initiation >= ? AND age_at_initiation <= ?",
                                                 @start_date, @end_date, min_age, max_age] if min_age and max_age
    initiation_join = 'INNER JOIN patient_start_dates ON 
    				 patient_start_dates.patient_id =
      			 patient_whole_tablets_remaining_and_brought.patient_id'

    total_registered = PatientRegistrationDate.find(:all, :joins => initiation_join, 
                               											:conditions => conditions).map(&:patient_id)


    date_art_last_taken_concept = Concept.find_by_name('Date last ARVs taken').id
    taken_arvs_concept = Concept.find_by_name('Taken ARVs in last 2 months').id
    ever_registered_concept = Concept.find_by_name('Ever registered at ART clinic').id
    hiv_registration_encounter = EncounterType.find_by_name('HIV First visit').id
    no_concept = Concept.find_by_name('NO').id
    yes_concept = Concept.find_by_name('YES').id

    total_reinitiated = PatientRegistrationDate.find_by_sql("SELECT patient_registration_dates.*                                    
																														FROM patient_registration_dates 
																														INNER JOIN encounter e ON e.patient_id = patient_registration_dates.patient_id
																														AND e.encounter_type = #{hiv_registration_encounter} 
																														AND e.encounter_datetime = (SELECT MAX(encounter_datetime) FROM encounter
																														INNER JOIN obs USING(encounter_id)
																														WHERE encounter_type = #{hiv_registration_encounter} AND voided = 0 
																														AND concept_id = #{ever_registered_concept} AND value_coded = #{yes_concept}
																														AND e.patient_id = encounter.patient_id GROUP BY encounter.patient_id)
																														INNER JOIN obs o ON o.patient_id = e.patient_id 
																														AND o.concept_id IN (#{date_art_last_taken_concept},#{taken_arvs_concept})
																														WHERE ((o.concept_id = #{date_art_last_taken_concept} AND o.voided = 0  AND               
																														(DATEDIFF(o.obs_datetime,o.value_datetime)) > 56) OR             
																														(o.concept_id = #{taken_arvs_concept} AND (o.value_coded = #{no_concept})))                                                                
																														AND patient_registration_dates.registration_date BETWEEN '#{@start_date}' 
																														AND '#{@end_date}' GROUP BY patient_registration_dates.patient_id
																														HAVING patient_registration_dates.patient_id IN(SELECT patient_id FROM obs 
																														WHERE concept_id = #{ever_registered_concept} 
																														AND value_coded = #{yes_concept} AND voided = 0 
																														AND obs_datetime BETWEEN '#{@start_date}' AND '#{@end_date}'  
																														GROUP BY patient_id)").map(&:patient_id)


    hiv_registration_encounter = EncounterType.find_by_name('HIV First visit').id

    total_transferred_in = PatientRegistrationDate.find(:all, 
																												:joins => "#{initiation_join} 
																												INNER JOIN encounter e ON e.patient_id = patient_registration_dates.patient_id
																												AND e.encounter_type = #{hiv_registration_encounter} 
																												AND e.encounter_datetime = (SELECT MAX(encounter_datetime) FROM encounter
																												INNER JOIN obs USING(encounter_id)
																												WHERE encounter_type = #{hiv_registration_encounter} AND voided = 0 
																												AND concept_id = #{Concept.find_by_name('Ever registered at ART clinic').id}
																												AND value_coded = #{Concept.find_by_name('Yes').id}
																												AND encounter.patient_id = e.patient_id GROUP BY encounter.patient_id)
																												INNER JOIN patient ON patient.patient_id = e.patient_id 
																												INNER JOIN obs ON obs.patient_id = patient.patient_id AND obs.voided = 0", 
																												:conditions => ["registration_date >= ? AND registration_date <= ? 
																												AND obs.concept_id = ? AND value_coded = ?", @start_date, @end_date, 
																												Concept.find_by_name('Ever registered at ART clinic').id,Concept.find_by_name('Yes').id],
																												:group => 'patient_id').map(&:patient_id) - total_reinitiated
				
   total_initiated = total_registered - total_transferred_in

   total_sum = total_transferred_in + total_reinitiated + total_initiated

   unless total_registered == total_sum
    		return false
    else
    		return true
    end
	    
  end
   
   
end
