class ValidationRule < ActiveRecord::Base
  has_many :validation_results
  
  def self.data_consistency_checks(date = Date.today)
    date = date.to_date
    require 'colorize'
    data_consistency_checks = {}
    #All methods for now should be here:
    data_consistency_checks['Patients without outcomes'] = "self.patients_without_outcomes(date)"
    data_consistency_checks['Patients with pills remaining greater than dispensed'] = "self.pills_remaining_over_dispensed(date)"
    data_consistency_checks['Patients without reason for starting'] = "self.validate_presence_of_start_reason"
    data_consistency_checks['Patients without reason for starting'] = "self.validate_presence_of_start_reason(date)"
    data_consistency_checks['Patients with missing dispensations'] = "self.prescrition_without_dispensation(date)"
		data_consistency_checks['Patients with missing prescriptions'] = "self.dispensation_without_prescription(date)"
		data_consistency_checks['Patients with dispensation without appointment'] = "self.dispensation_without_appointment(date)"
		data_consistency_checks['Patients with vitals without weight'] = "self.validate_presence_of_vitals_without_weight(date)"
		data_consistency_checks['Patients with encounters before birth or after death'] = "self.death_date_less_than_last_encounter_date_and_less_than_date_of_birth(date)"
		data_consistency_checks['Patients with encounters without obs or orders'] = "self.encounters_without_obs_or_orders(date)"
		data_consistency_checks['Patients with ART start date before birth'] = "self.start_date_before_birth(date)"
		data_consistency_checks['Dead patients with follow up visits'] = "self.visit_after_death(date)"
		data_consistency_checks['Male patients with pregnant observations'] = "self.male_patients_with_pregnant_obs(date)"
		data_consistency_checks['Male patients with breastfeeding observations'] = "self.male_patients_with_breastfeeding_obs(date)"
		data_consistency_checks['Male patients with family planning methods obs'] = "self.male_patients_with_family_planning_methods_obs(date)"
		data_consistency_checks['ART patients without HIV clinic registration encounter'] = "self.check_every_ART_patient_has_HIV_First_Visit(date)"
		data_consistency_checks['Under 18 patients without height and weight in visit'] = "self.every_visit_of_patients_who_are_under_18_should_have_height_and_weight(date)"
		data_consistency_checks['Patients with outcomes without date'] = "self.every_outcome_needs_a_date(date)"
		
		data_consistency_checks = data_consistency_checks.keys.inject({}){|hash, key| 
      time = Time.now
      puts "Running query for #{key}"
      hash[key] = eval(data_consistency_checks[key])
      period = (Time.now - time).to_i
      color = hash[key].length > 0 ? "red" : "green"
      eval("puts 'Time taken  :  #{(period/60).to_i} min  and #{(period % 60)} sec  --> #{hash[key].length} patient(s) found'.#{color}")
      puts ""
      hash}
		
		
    set_rules = self.find(:all,:conditions =>['type_id = 2'])                   
    (set_rules || []).each do |rule|                                            
      unless data_consistency_checks[rule.desc].blank?                          
        create_update_validation_result(rule, date, data_consistency_checks[rule.desc])
      end                                                                       
    end                                                                         
                                                                                
    return data_consistency_checks
  end

  def self.create_update_validation_result(rule, date, patient_ids)
    date_checked = date.to_date                                                 
    v = ValidationResult.find(:first,                                           
      :conditions =>["date_checked = ? AND rule_id = ?", date_checked,rule.id]) 

    return ValidationResult.create(:rule_id => rule.id, :failures => patient_ids.length,
      :date_checked => date_checked) if v.blank?                                
                                                                                
    v.failures = patient_ids.length                                             
    v.save
  end

  def self.validate_presence_of_start_reason(end_date = Date.today)
    #This function checks for patients who do not have a reason for starting ART

    start_reason_id = PersonAttributeType.find_by_name("Reason antiretrovirals started").id
    art_patients = Patient.find_by_sql("SELECT patient_id FROM patient_registration_dates where registration_date <= '#{end_date}' AND
                      patient_id not in (SELECT person_id from person_attribute where person_attribute_type_id = #{start_reason_id} and voided = 0)")

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
                                  )").map(&:patient_id)
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
                                  AND patient_id = encounter.patient_id)").map(&:patient_id)
    return undispensed
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
                                  AND patient_id = encounter.patient_id)").map(&:patient_id)
    return no_appointment
  end

  def self.death_date_less_than_last_encounter_date_and_less_than_date_of_birth(end_date = Date.today)
    #Task 41

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

  def self.check_every_ART_patient_has_HIV_First_Visit(date = Date.today)
    #Task 32
    #SQL to check for every ART patient should have an HIV First Visit

    date = date.to_date.strftime('%Y-%m-%d 23:59:59')
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

	def self.every_visit_of_patients_who_are_under_18_should_have_height_and_weight(date = Date.today)

		#Task 31
		#SQL for every visit of patients who are under 18 should have height and weight

		date = date.to_date.strftime('%Y-%m-%d 23:59:59')
		encounter_type_id = EncounterType.find_by_name("Height/Weight").encounter_type_id
		height_id = Concept.find_by_name("Height").concept_id
		weight_id = Concept.find_by_name("Weight").concept_id

		Patient.find_by_sql("
			SELECT Weight_and_Height, patient_id, encounter_datetime, concept_id
			FROM(
					SELECT COUNT(*) AS Weight_and_Height, visit.* , e.encounter_type, o.concept_id, value_numeric
						  FROM (
						      SELECT e.patient_id, DATE(e.encounter_datetime) AS encounter_datetime, birthdate,
						          FLOOR(DATEDIFF(DATE(e.encounter_datetime), birthdate)/365) AS age
						      FROM encounter e LEFT JOIN patient p ON e.patient_id = p.patient_id
						      GROUP BY e.patient_id, DATE(e.encounter_datetime)) visit
						  LEFT JOIN encounter e ON visit.patient_id = e.patient_id
						      AND visit.encounter_datetime = DATE(e.encounter_datetime)
						  LEFT JOIN obs o ON e.encounter_id=o.encounter_id
					WHERE age < 18 AND e.encounter_type = #{encounter_type_id} AND concept_id IN (#{height_id}, #{weight_id})
					GROUP BY visit.patient_id, visit.encounter_datetime) weight_and_height_check
			WHERE Weight_and_Height < 2 AND encounter_datetime <= DATE('#{date}')").map(&:patient_id)
	end

	def self.every_outcome_needs_a_date(date = Date.today)

		#Task #40
		#Every outcome needs a date
		date = date.to_date.strftime('%Y-%m-%d 23:59:59')

		PatientHistoricalOutcome.all(:conditions=>["outcome_date is null"]).map(&:patient_id)
	end

  def self.patients_without_outcomes(visit_date)
    visit_date = visit_date.to_date rescue Date.today
    connection = ActiveRecord::Base.connection
    patient_ids = []
    art_patients = connection.select_all("SELECT patient_id FROM patient_registration_dates").collect{|patient|patient["patient_id"]}.uniq.join(', ')
    without_outcome_ids = connection.select_all("
        SELECT e.patient_id  FROM encounter e INNER JOIN patient p
        ON e.patient_id=p.patient_id LEFT JOIN patient_historical_outcomes pho ON
        pho.patient_id=p.patient_id WHERE e.patient_id IN (#{art_patients})
        AND pho.outcome_concept_id IS NULL AND DATE(e.encounter_datetime) <= \'#{visit_date}\'
        GROUP BY patient_id
      ")
    without_outcome_ids.each do |pid|
      patient_ids << pid["patient_id"]
    end
    return patient_ids
  end

  def self.pills_remaining_over_dispensed(visit_date)
    visit_date = visit_date.to_date rescue Date.today
    patient_ids = []
    give_drugs_enc = EncounterType.find_by_name('GIVE DRUGS').id #for finding total drugs dispensed
    art_visit_enc = EncounterType.find_by_name('ART VISIT').id # for finding drugs brought to clinic
    amount_brought_to_clinic_concept = Concept.find_by_name('WHOLE TABLETS REMAINING AND BROUGHT TO CLINIC').id

    patient_ids = Patient.find_by_sql("
      SELECT e.patient_id as patient_ID, o.value_numeric as amought_brought_to_clinic,
      e.encounter_datetime as visit FROM encounter e INNER JOIN
      obs o ON o.encounter_id = e.encounter_id AND encounter_type = #{art_visit_enc} AND
      o.concept_id= #{amount_brought_to_clinic_concept} AND o.voided=false AND
      DATE(e.encounter_datetime) <= \'#{visit_date}\'
      HAVING
      amought_brought_to_clinic > (
      SELECT do.quantity FROM encounter INNER JOIN
      orders o ON o.encounter_id=encounter.encounter_id INNER JOIN drug_order do  ON
      do.order_id=o.encounter_id AND encounter.encounter_type = #{give_drugs_enc}
      AND encounter.patient_id = patient_ID AND o.voided=false
      WHERE encounter.encounter_datetime < visit AND DATEDIFF(visit, encounter.encounter_datetime) >30 ORDER BY encounter.encounter_datetime
asc LIMIT 1)
      ").collect{|patient|patient["patient_ID"]}
    return patient_ids
  end
  
end
