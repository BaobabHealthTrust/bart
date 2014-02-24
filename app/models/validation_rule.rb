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

  def self.dispensation_without_prescription(end_date = Date.today)
    unprescribed = Observation.find_by_sql("
                                  SELECT DISTINCT(encounter.patient_id)
                                  FROM orders
                                  INNER JOIN encounter USING(encounter_id)
                                  INNER JOIN drug_order USING(order_id)
                                  INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id
                                  INNER JOIN concept_set ON concept_set.concept_id = drug.concept_id
                                  WHERE concept_set.concept_set = 460
                                  AND DATE(orders.start_date)  <= '#{end_date}' AND
                                  orders.voided = 0 AND
                                  NOT EXISTS (
                                  SELECT patient_id, DATE(p.prescription_datetime) AS visit_date, p.drug_id
                                  FROM patient_prescriptions p
                                  WHERE encounter.patient_id = p.patient_id  AND
                                  DATE(encounter_datetime) = DATE(p.prescription_datetime) AND
                                  p.drug_id = drug_order.drug_inventory_id
                                  )").length
    return unprescribed
  end

  def self.prescrition_without_dispensation(end_date = Date.today)
    undispensed = Order.find_by_sql("
                                  SELECT DISTINCT(encounter.patient_id) FROM orders
                                  INNER JOIN encounter USING(encounter_id)
                                  INNER JOIN drug_order USING(order_id)
                                  WHERE orders.voided = 0
                                  AND DATE(orders.start_date)  <= '#{end_date}'
                                  AND NOT EXISTS (
                                  SELECT patient_id FROM obs
                                  WHERE concept_id = (SELECT concept_id FROM concept WHERE name = 'APPOINTMENT DATE')
                                  AND DATE(encounter_datetime) = DATE(obs_datetime)
                                  AND patient_id = encounter.patient_id)")
    return undispensed.length
  end

  def self.dispensation_without_appointment(end_date = Date.today)
    no_appointment = Observation.find_by_sql("
                                  SELECT DISTINCT(encounter.patient_id) FROM orders
                                  INNER JOIN encounter USING(encounter_id)
                                  INNER JOIN drug_order USING(order_id)
                                  WHERE orders.voided = 0
                                  AND DATE(orders.start_date)  <= '#{end_date}'
                                  AND NOT EXISTS (
                                  SELECT patient_id FROM obs
                                  WHERE concept_id = (SELECT concept_id FROM concept WHERE name = 'APPOINTMENT DATE')
                                  AND DATE(encounter_datetime) = DATE(obs_datetime)
                                  AND patient_id = encounter.patient_id)")
    return no_appointment.length
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

  def self.check_every_ART_patient_has_HIV_First_Visit(date)
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

    #Query pulling all male patients with pregnant observations
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

    #Query pulling all male patients with breastfeeding observations
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

    #Query pulling all male patients with family planning methods observations
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
  
	def self.encounters_without_obs_or_orders(end_date = Date.today)
		
		# Query for encounters without obs or orders
		# By kenneth Kapundi
		
		start_date = Encounter.find_by_sql("SELECT MIN(encounter_datetime) start_date FROM encounter")
		start_date = start_date.blank? ? "1900-01-01 00:00:00" : start_date.first.start_date
				
		self.find_by_sql(["
			SELECT DISTINCT (enc.patient_id) FROM encounter enc
					LEFT JOIN obs o ON o.encounter_id = enc.encounter_id
					LEFT JOIN orders od ON od.encounter_id = enc.encounter_id
			WHERE o.encounter_id IS NULL AND od.encounter_id IS NULL
				AND enc.encounter_datetime BETWEEN ? AND ?", start_date, end_date  
			]).map(&:patient_id)		
		
	end
	
	def self.start_date_before_birth(end_date = Date.today)
		
		# Query for patients whose earliest start date is less that date of birth
		# By Kenneth Kapundi
		
		start_date = Encounter.find_by_sql("SELECT MIN(encounter_datetime) start_date FROM encounter")
		start_date = start_date.blank? ? "1900-01-01 00:00:00" : start_date.first.start_date
		
		self.find_by_sql(["
			SELECT DISTINCT(prd.patient_id) FROM patient_registration_dates prd 
    		INNER JOIN patient p ON p.patient_id = prd.patient_id AND p.voided = 0
    		INNER JOIN encounter enc ON enc.patient_id = prd.patient_id
			WHERE DATEDIFF(prd.registration_date, p.birthdate) <= 0
				AND enc.encounter_datetime BETWEEN ? AND ?", start_date, end_date  
			]).map(&:patient_id)		
		
	end
	
	def self.visit_after_death(end_date = Date.today)
		
		# Query for patients with followup visit after death
		# By Kenneth Kapundi
		
		start_date = Encounter.find_by_sql("SELECT MIN(encounter_datetime) start_date FROM encounter")
		start_date = start_date.blank? ? "1900-01-01 00:00:00" : start_date.first.start_date
		
		self.find_by_sql(["
		SELECT DISTINCT(p.patient_id) FROM patient p 
    		INNER JOIN encounter enc ON enc.patient_id = p.patient_id 
        	AND p.voided = 0 AND enc.encounter_datetime > p.death_date
			WHERE enc.encounter_datetime BETWEEN ? AND ?", start_date, end_date  
			]).map(&:patient_id)		
			
	end	

>>>>>>> 3637abfb193f85699fe8e1a18ba0b50595b6e4c1
end
