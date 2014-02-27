class CohortValidation
    
	attr_accessor :cohort_object, :quart_cohort, :cum_cohort

	def initialize(cohort_obj)

		self.cohort_object = cohort_obj
		self.quart_cohort = cohort_obj["quarterly_data"]
		self.cum_cohort = cohort_obj["cumulative_data"]	
	end

	def get_all_differences
	 
	 #This code runs all methods that start with 'validate_' 
	 #And returns a hash of all return values from such methods
	 #By Kenneth Kapundi	 

		differences = {}
		(self.class.instance_methods(false) - Object.methods).each do |method|
			next if !method.match(/^validate\_/) 
			validation = method.sub(/^validate\_/, "").humanize
			differences[validation] = self.send(method) unless validation.blank?
		end

		return differences
	end
	
	def feed_values(expr, val_arr)
		#This method takes an expression and replaces the curly 
		#brackets with values from the val_arr array based on position.
		#By Kenneth Kapundi
		
		return nil if expr.scan(/\{\w+\}/).length != val_arr.length
		return eval(val_arr.inject(expr){|out_str, val| out_str = out_str.sub(/\{\w+\}/, "#{val}"); out_str})				
	end
	
		
	#***************SAMPLE USAGE****************************
	#To be removed later on.
	#By Kenneth Kapundi
	def validate_sample_rule		
		
		validation_rule = ValidationRule.find_by_type_id(1)
		return nil if validation_rule.blank?
				
		values = [self.quart_cohort['all_patients'],
				 				self.quart_cohort['child_patients'], 
			 					self.quart_cohort['adult_patients'],
			 					self.quart_cohort['adult_patients']]
			 					
		return self.feed_values(validation_rule.expr, values)		
	end
	
	def validate_kaposis_sarcoma_less_than_total_registered_in_quarter
		#This method checks that cases of kaposis sarcoma are less than total registered in quarter	
		#By Kenneth Kapundi
			
		validation_rule = ValidationRule.find_by_desc('Patients with kaposis sarcoma')
		return nil if validation_rule.blank?
				
		values = [self.quart_cohort['start_cause_KS'],
				 			self.quart_cohort['all_patients']]			 					
		return self.feed_values(validation_rule.expr, values)		
	end
	
	def validate_cumulative_kaposis_sarcoma_less_than_total_ever_registered
		#This method checks that all scases of kaposis sarcoma are less than total ever registered
		#By Kenneth Kapundi
			
		validation_rule = ValidationRule.find_by_desc('Patients with kaposis sarcoma')
		return nil if validation_rule.blank?
				
		values = [self.cum_cohort['start_cause_KS'],
				 			self.cum_cohort['all_patients']]			 					
		return self.feed_values(validation_rule.expr, values)		
	end	
	
	def validate_all_outcomes_equal_to_cumulative_total_registered
		#This method checks that outcome totals dont exceed total registered	
		#By Kenneth Kapundi
		
		validation_rule = ValidationRule.find_by_desc("Died total, Total alive and on ART, Defaulted (more than 2 months overdue after expected to have run out of ARVs), Stopped taking ARVs (clinician or patient own decision last known alive), Transfered out, and Unknown outcome should add up to Total registe")
		
		return nil if validation_rule.blank?

		values = [self.cum_cohort['all_patients'],
							self.cum_cohort['dead_patients'],
							self.cum_cohort['alive_on_ART_patients'],
							self.cum_cohort['defaulters'],
							self.cum_cohort['art_stopped_patients'],
							self.cum_cohort['transferred_out_patients'],
							self.cum_cohort['patients_with_unknown_outcomes']]			 					
		return self.feed_values(validation_rule.expr, values)		
	end

 def validate_total_registered_is_sum_of_intitiated_reinitiated_and_transfer_in
    #Task 48
    #ammendment: PB-2014-02-27 - Added missing return and end for this method.
     
    validation_rule = ValidationRule.find_by_desc("[QUARTER] FT: Patients initiated on ART first time, Re: Patients re-initiated on ART, and TI: Patients transfered in on ART should add up to Total registered")
    return nil if validation_rule.blank?
        
    values = [self.quart_cohort['all_patients'],
              self.quart_cohort['new_patients'],
              self.quart_cohort['re_initiated_patients'],
							self.quart_cohort['transfer_in_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end

  def validate_cumulative_total_registered_is_sum_of_intitiated_reinitiated_and_transfer_in
    #Task 48
   
    validation_rule = ValidationRule.find_by_desc("[CUMULATIVE] FT: Patients initiated on ART first time, Re: Patients re-initiated on ART, and TI: Patients transfered in on ART should add up to Total registered")
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['all_patients'],
              self.cum_cohort['new_patients'],
              self.cum_cohort['re_initiated_patients'],
							self.cum_cohort['transfer_in_patients']
                ]
    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_all_regimens_not_equal_to_total_alive_and_on_art
    #validating sum of all regimens should add up to total_alive_and_on_art

    validation_rule = ValidationRule.find_by_desc("1A (D4T+3TC+NVP), 1P (D4T+3TC+NVP), 2A (AZT+3TC+NVP), 2P (AZT+3TC+NVP), 3A (D4T+3TC+EFV), 3P (D4T+3TC+EFV), 4A (AZT+3TC+EFV), 4P (AZT+3TC+EFV), 5A (TDF+3TC+EFV), 6A (TDF+3TC+NVP), 7A (TDF+3TC+LPV/r), 8A (AZT+3TC+LPV/r), 9P (ABC+3TC+LPV/r), and Non-standar")
    return nil if validation_rule.blank?

    values = [self.cum_cohort['alive_on_ART_patients'],
              self.cum_cohort['1A'],
              self.cum_cohort['1P'],
              self.cum_cohort['2A'],
              self.cum_cohort['2P'],
              self.cum_cohort['3A'],
              self.cum_cohort['3P'],
              self.cum_cohort['4A'],
              self.cum_cohort['4P'],
              self.cum_cohort['5A'],
              self.cum_cohort['6A'],
              self.cum_cohort['7A'],
              self.cum_cohort['8A'],
              self.cum_cohort['9P'],
              self.cum_cohort['Other Regimen']]

   return self.feed_values(validation_rule.expr, values)
  end

  def validate_quartely_all_ages_should_equal_to_quartely_total_registered
    #validating quartery sum of infants+children+adults+unknow_age
    #should equal to quartly total registered

    validation_rule = ValidationRule.find_by_desc("[QUARTER] A: Infants (0<24 months at ART initiation), B: Children (24 mths -14 yrs at ART initiation), C: Adults (15 years or older at ART initiation), and Unknown age should add up to Total registered")
    return nil if validation_rule.blank?

    values = [self.quart_cohort['all_patients'],
              self.quart_cohort['adult_patients'],
              self.quart_cohort['child_patients'],
              self.quart_cohort['adult_patients'],
              self.quart_cohort['patients_with_unknown_age']]

    return self.feed_values(validation_rule.expr, values)
  end

  def validate_total_alive_and_side_effects
    #Task 57
   
    validation_rule = ValidationRule.find_by_desc("Total patients with side effects should not exceed Total alive and on ART")
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['alive_on_ART_patients'],
              self.cum_cohort['side_effect_patients']
                ]


    return self.feed_values(validation_rule.expr, values)
  end
		 
  def validate_cumulative_all_ages_should_equal_to_cumulative_total_registered
    #validating cumulative sum of infants+children+adults+unknow_age
    #should equal to cumulative total registered

    validation_rule = ValidationRule.find_by_desc("[CUMULATIVE] A: Infants (0<24 months at ART initiation), B: Children (24 mths -14 yrs at ART initiation), C: Adults (15 years or older at ART initiation), and Unknown age should add up to Total registered")
    return nil if validation_rule.blank?

    values = [self.cum_cohort['all_patients'],
              self.cum_cohort['adult_patients'],
              self.cum_cohort['child_patients'],
              self.cum_cohort['adult_patients'],
              self.cum_cohort['patients_with_unknown_age']]

    return self.feed_values(validation_rule.expr, values)
  end
  
	def validate_sum_of_tb_equal_total_alive_and_on_ART
		#Task 59
		#Sum of tb = total alive and on ART

		validation_rule = ValidationRule.find_by_desc("TB not suspected, TB suspected, TB confirmed not yet/currently not on TB treatment, TB confirmed on TB treatment, and Unknown TB status should add up to Total alive and on ART")

		return nil if validation_rule.blank?

		values = [self.cum_cohort['alive_on_ART_patients'],
				 			self.cum_cohort['tb_not_suspected_patients'],
				 			self.cum_cohort['tb_suspected_patients'],
				 			self.cum_cohort['tb_confirmed_not_on_treatment_patients'],
				 			self.cum_cohort['tb_confirmed_on_treatment_patients'],
				 			self.cum_cohort['tb_status_unknown_patients']
				 			]
		return self.feed_values(validation_rule.expr, values)
	end
	
	def validate_sum_of_reason_starting_ART_equal_total_registered
		#Task 51
		#sum of reason starting ART equal to total registered

		validation_rule = ValidationRule.find_by_desc("[CUMULATIVE] Presumed severe HIV disease in infants, Confirmed HIV infection in infants (PCR), WHO stage 1 or 2, CD4 below threshold, , Children 12-23 mths, Breastfeeding mothers, Pregnant women, WHO stage 3, WHO stage 4, and Unknown/other reason outside ")
		return nil if validation_rule.blank?

		values = [self.cum_cohort['all_patients'],
							self.cum_cohort['infants_presumed_severe_HIV'],
							self.cum_cohort['infants_PCR'],
							self.cum_cohort['who_stage_1_or_2_cd4'],
							self.cum_cohort['who_stage_2_lymphocyte'],
							self.cum_cohort['child_patients'],
							self.cum_cohort['breastfeeding_mothers'],
							self.cum_cohort['started_cause_pregnant'],
							self.cum_cohort['who_stage_3'],
							self.cum_cohort['who_stage_4'],
							self.cum_cohort['start_reason_other']
				 		 ]
		return self.feed_values(validation_rule.expr, values)
	end
	
	def validate_cumulative_died_intervals_sum_up_to_died_total
		#This method checks that the sum of figures in died intervals should equal died total	
		#By Kenneth Kapundi
		
		validation_rule = ValidationRule.find_by_desc("Died within the 1st month after ART initiation, Died within the 2nd month after ART initiation, Died within the 3rd month after ART initiation, and Died after the end of the 3rd month after ART initiation should add up to Died total")
		
		return nil if validation_rule.blank?
				
		values = [self.cum_cohort['dead_patients'],
				 			self.cum_cohort['died_1st_month'],
				 			self.cum_cohort['died_2nd_month'],
				 			self.cum_cohort['died_3rd_month'],
				 			self.cum_cohort['died_after_3rd_month']
				 			]			 					
		return self.feed_values(validation_rule.expr, values)		
	end

  def validate_adherence_sum_zero_to_six_and_seven_plus_needs_to_equal_total_alive_and_on_art
     validation_rule = ValidationRule.find_by_desc("Patients with 0-6 doses missed at their last visit(before end of quarter evaluated), and Patients with 7+ doses missed at their last visit(before end of quarter evaluated) should add up to Total alive and on ART")
     return nil if validation_rule.blank?
     values = [self.cum_cohort['alive_on_ART_patients'],
				 			self.cum_cohort['patients_with_few_dosses_missed'],
				 			self.cum_cohort['patients_with_more_dosses_missed']
				 			]
		return self.feed_values(validation_rule.expr, values)
     
  end

  def validate_sum_of_stage_defining_conditions_needs_to_equal_total_registered
    validation_rule = ValidationRule.find_by_desc("[CUMULATIVE] No TB, TB within the last 2 years, Current episode of TB, and Kaposis Sarcoma should add up to Total registered")
    return nil if validation_rule.blank?
    values = [self.cum_cohort['all_patients'],
				 			self.cum_cohort['start_cause_no_tb'],
				 			self.cum_cohort['start_cause_tb_within_two_years'],
				 			self.cum_cohort['start_cause_current_tb'],
				 			self.cum_cohort['start_cause_KS']
				 			]
		return self.feed_values(validation_rule.expr, values)		
    
  end
  
  def validate_new_total_male_plus_total_pregnant_plus_total_nonpregnant_equals_total_registered
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Newly (registered males + 
    #                               registered females (pregnant) + 
    #                               registered females (non -pregnant)) =
    #                               total registered  
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{new_total_reg} == {new_males} + {new_non_preg} + {new_preg_all_age}')
    return nil if validation_rule.blank?
        
    values = [self.quart_cohort['all_patients'],
              self.quart_cohort['male_pattients'],
              self.quart_cohort['non_pregnant_women'], 
              self.quart_cohort['pmtct_pregnant_women_on_art']
                ]
         
    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_total_male_plus_total_pregnant_plus_total_nonpregnant_equals_total_registered
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate cumulative (registered males + 
    #                                   registered females (pregnant) + 
    #                                   registered females (non -pregnant)) =
    #                                   total registered  
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_total_reg} == {cum_males} + {cum_non_preg} + {cum_preg_all_age}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['all_patients'],
              self.cum_cohort['male_pattients'],
              self.cum_cohort['non_pregnant_women'], 
              self.cum_cohort['pmtct_pregnant_women_on_art']
                ]
    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_total_registered
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Total Registered (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_total_reg}>={new_total_reg}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['all_patients'],
              self.quart_cohort['all_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
    
  end
  
  def validate_cumulative_and_new_patients_initiated_first_time
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate patients initiated first time on ART (Cumulative >= New)
    # Amendments  :

   
    validation_rule = find_by_expr('{cum_ft}>={new_ft}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['new_patients'],
              self.quart_cohort['new_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_patients_reinitiated
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Patients reinitiated on ART (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_re}>={new_re}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['re_initiated_patients'],
              self.quart_cohort['re_initiated_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_transferedin_on_art
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Patients transfered in on ART (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_ti}>={new_ti}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['transfer_in_patients'],
              self.quart_cohort['transfer_in_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end 
  
  def validate_cumulative_and_new_registered_males
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Registered Males  (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_males}>={new_males}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['male_patients'],
              self.quart_cohort['male_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_non_pregnant_females
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate non pregnant females  (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_non_preg}>={new_non_preg}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['non_pregnant_women)'],
              self.quart_cohort['non_pregnant_women']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_pregnant_females
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate pregnant females  (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_preg_all_age}>={new_preg_all_age}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['pmtct_pregnant_women_on_art'],
              self.quart_cohort['pmtct_pregnant_women_on_art']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_children_below_24_months
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate children below 24 months (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_a}>={new_a}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['infant_patients'],
              self.quart_cohort['infant_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end 
  
  def validate_cumulative_and_new_children_between_24_months_and_14_years
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate children between 24 months and 14 years (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_b}>={new_b}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['child_patients'],
              self.quart_cohort['child_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end 
  
  def validate_cumulative_and_new_adults
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate adults (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_c}>={new_c}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['adult_patients'],
              self.quart_cohort['adult_patients']
                ]

    return self.feed_values(validation_rule.expr, values)
  end 
=begin  
  def validate_cumulative_and_new_unknown_age
    
    # Developer   : Precious Bondwe
    # Date        : 25/02/2014
    # Purpose     : Validate unknown age (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_unk_age}>={new_unk_age}')
    return nil if validation_rule.blank?
        
    values = [self.cohort_object['Total Unknown age'],
              self.cohort_object['Newly Unknown age']
                ]

    return self.feed_values(validation_rule.expr, values)
  end 
=end

  def validate_cumulative_and_new_presumed_severe_hiv_in_infants
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of presumed severe HIV in infants (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_pres_hiv}>={new_pres_hiv}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['infants_presumed_severe_HIV'],
              self.quart_cohort['infants_presumed_severe_HIV']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_confirmed_hiv_infection_in_infants
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of presumed severe confirmed HIV infection in infants (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_conf_hiv}>={new_conf_hiv}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['infants_PCR'],
              self.quart_cohort['infants PCR']
                ]
    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_pregnant_women
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of pregnant women (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_preg}>={new_preg}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['started_cause_pregnant'],
              self.quart_cohort['started_cause_pregnant']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_breastfeeding_mothers
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of breastfeeding mothers (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_breastfeed}>={new_breastfeed}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['breastfeeding mothers'],
              self.quart_cohort['breastfeeding mothers']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_WHO_stage_1_or_2_cd4_count_below_threshhold
    
    # Developer   : Precious Bondwe
    # Date        : 26/02/2014
    # Purpose     : Validate Reason for Starting of WHO stage 1 or 2 with cd4 count below threshhold (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_who_1_2}>={new_who_1_2}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['who_stage_1_or_2_cd4'],
              self.quart_cohort['who_stage_1_or_2_cd4']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_WHO_stage_2_total_lymphocytes
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of WHO stage 2 total lymphocytes (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_who_2}>={new_who_2}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['who_stage_2_lymphocytes'],
              self.quart_cohort['who_stage_2_lymphocytes']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_WHO_stage_3
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of WHO stage 3 (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_who_3}>={new_who_3}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['who_stage_3'],
              self.quart_cohort['who_stage_3']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_WHO_stage_4
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of WHO stage 4 (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_who_4}>={new_who_4}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['who_stage_4'],
              self.quart_cohort['who_stage_4']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_unknown_reason
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of Unknown reason (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_other_reason}>={new_other_reason}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['start_reason_other'],
              self.quart_cohort['start_reason_other']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_TB_within_last_2_years
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Stage Defining Conditions of TB within last 2 years (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_tb_w2yrs}>={new_tb_w2yrs}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['start_cause_tb_within_two_years'],
              self.quart_cohort['start_cause_tb_within_two_years']
                ]
    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_current_episode_of_TB
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Current Episode of TB (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_current_tb}>={new_current_tb}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['start_cause_current_tb'],
              self.quart_cohort['start_cause_current_tb']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_kaposis_sarcoma
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Stage Defining Conditions of Kaposis Sarcoma (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_ks}>={new_ks}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['start_cause_KS'],
              self.quart_cohort['start_cause_KS']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_no_TB
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Stage Defining Conditions of no TB (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_no_tb}>={new_no_tb}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['start_cause_no_tb'],
              self.quart_cohort['start_cause_no_tb']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
  
  def validate_cumulative_and_new_Children_12_to_23_months
    
    # Developer   : Precious Bondwe
    # Date        : 27/02/2014
    # Purpose     : Validate Reason for Starting of Children 12 - 23 months (Cumulative >= New)
    # Amendments  :

   
    validation_rule = ValidationRule.find_by_expr('{cum_children}>={new_children}')
    return nil if validation_rule.blank?
        
    values = [self.cum_cohort['child_hiv_positive'],
              self.quart_cohort['child_hiv_positive']
                ]

    return self.feed_values(validation_rule.expr, values)
  end
end

