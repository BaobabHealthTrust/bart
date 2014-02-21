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
  
  def self.validate_presence_of_vitals_without_weight(end_date)
    # Developer   : Precious Bondwe
    # Date        : 21/02/2014
    # Purpose     : Return Patient IDs for patients having Vitals encounters without weight 
    # Amendments  :

    weight_concept = Concept.find_by_name('weight').concept_id
    encounter_type = EncounterType.find_by_name('Height/Weight').id
    
    patient_ids = ValidationRule.find_by_sql("SELECT DISTINCT e.patient_id 
                          FROM encounter e 
                              LEFT JOIN obs o ON e.encounter_id = o.encounter_id AND o.concept_id = #{weight_concept} AND o.voided = 0
                               WHERE o.concept_id IS NULL AND e.encounter_type = #{encounter_type}   
                               AND e.encounter_datetime <= '#{end_date}'").map(&:patient_id) 
    
    return patient_ids 
  end

  def self.check_every_ART_patient_has_HIV_Clinical_Registration(date)
			#Task 32
			#SQL to check for every ART patient should have an HIV First Visit

			encounter_type_id = EncounterType.find_by_name("HIV First visit").encounter_type_id

			PatientRegistrationDate.find_by_sql("
				SELECT p.patient_id
				FROM patient_registration_dates p LEFT JOIN (SELECT * FROM encounter WHERE encounter_type = #{encounter_type_id}) e 
						ON p.patient_id = e.patient_id
				WHERE e.encounter_type IS NULL AND p.registration_date <= DATE('#{date}');
			").map(&:patient_id)
	end

  def self.male_patients_with_pregnant_obs(end_date = Date.today)
    @end_date = end_date.to_date.strftime('%Y-%m-%d 23:59:59')

    pregnant_ids = [Concept.find_by_name("PREGNANT").concept_id,
                    Concept.find_by_name("PREGNANT WHEN ART WAS STARTED").concept_id]

    male_pats_with_preg_obs = ValidationRule.find_by_sql("
                                      SELECT prd.patient_id, p.gender,
                                             prd.registration_date, o.concept_id,
                                             o.value_coded, o.obs_datetime
                                      FROM patient_registration_dates prd
	                                      INNER JOIN patient p ON p.patient_id = prd.patient_id
	                                        AND p.voided = 0
                                        INNER JOIN obs o ON o.patient_id = p.patient_id
                                         AND o.voided = 0
                                      WHERE p.gender = 'Male'
                                      AND (o.concept_id IN (#{pregnant_ids.join(',')})
                                        OR o.value_coded IN (#{pregnant_ids.join(',')}))
                                      AND o.obs_datetime <= '#{@end_date}'
                                      GROUP BY prd.patient_id").collect{|p| p.patient_id}
  end

  def self.male_patients_with_breastfeeding_obs(end_date = Date.today)
    @end_date = end_date.to_date.strftime('%Y-%m-%d 23:59:59')

    breastfeeding_id = Concept.find_by_name("BREASTFEEDING").concept_id

    male_pats_with_breastfeed_obs = ValidationRule.find_by_sql("
                                      SELECT prd.patient_id, p.gender,
                                             prd.registration_date, o.concept_id,
                                             o.value_coded, o.obs_datetime
                                      FROM patient_registration_dates prd
	                                      INNER JOIN patient p ON p.patient_id = prd.patient_id
	                                        AND p.voided = 0
                                        INNER JOIN obs o ON o.patient_id = p.patient_id
                                         AND o.voided = 0
                                      WHERE p.gender = 'Male'
                                      AND (o.concept_id = #{breastfeeding_id}
                                        OR o.value_coded = #{breastfeeding_id})
                                      AND o.obs_datetime <= '#{@end_date}'
                                      GROUP BY prd.patient_id").collect{|p| p.patient_id}
  end

  def self.male_patients_with_family_planning_methods_obs(end_date = Date.today)
    @end_date = end_date.to_date.strftime('%Y-%m-%d 23:59:59')

    family_planning_ids = [Concept.find_by_name("FAMILY PLANNING METHOD").concept_id,
                         Concept.find_by_name("CURRENTLY USING FAMILY PLANNING METHOD").concept_id]

    male_pats_with_family_planning_obs = ValidationRule.find_by_sql("
                                            SELECT prd.patient_id, p.gender,
                                                   prd.registration_date, o.concept_id,
                                                   o.value_coded, o.obs_datetime
                                            FROM patient_registration_dates prd
	                                            INNER JOIN patient p ON p.patient_id = prd.patient_id
	                                              AND p.voided = 0
                                              INNER JOIN obs o ON o.patient_id = p.patient_id
                                               AND o.voided = 0
                                            WHERE p.gender = 'Male'
                                            AND (o.concept_id IN (#{family_planning_ids.join(',')})
                                              OR o.value_coded IN (#{family_planning_ids.join(',')}))
                                            AND o.obs_datetime <= '#{@end_date}'
                                            GROUP BY prd.patient_id").collect{|p| p.patient_id}
  end

end
