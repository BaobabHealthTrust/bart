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

	def validate_sum_of_tb_equal_total_alive_and_on_ART
		#Task 59
		#Sum of tb = total alive and on ART

		validation_rule = ValidationRule.find_by_desc("TB not suspected, TB suspected, TB confirmed not yet/currently not on TB treatment, TB confirmed on TB treatment, and Unknown TB status should add up to Total alive and on ART")

		return nil if validation_rule.blank?

		values = [self.cohort_object['alive_on_ART_patients'],
				 			self.cohort_object['tb_not_suspected_patients'],
				 			self.cohort_object['tb_suspected_patients'],
				 			self.cohort_object['tb_confirmed_not_on_treatment_patients'],
				 			self.cohort_object['tb_confirmed_on_treatment_patients'],
				 			self.cohort_object['tb_status_unknown_patients']
				 			]
		return self.feed_values(validation_rule.expr, values)
	end
	
	def validate_sum_of_reason_starting_ART_equal_total_registered
		#Task 51
		#sum of reason starting ART equal to total registered

		validation_rule = ValidationRule.find_by_desc("[CUMULATIVE] Presumed severe HIV disease in infants, Confirmed HIV infection in infants (PCR), WHO stage 1 or 2, CD4 below threshold, , Children 12-23 mths, Breastfeeding mothers, Pregnant women, WHO stage 3, WHO stage 4, and Unknown/other reason outside ")
		return nil if validation_rule.blank?

		values = [self.cohort_object['all_patients'],
							self.cohort_object['infants_presumed_severe_HIV'],
							self.cohort_object['infants_PCR'],
							self.cohort_object['who_stage_1_or_2_cd4'],
							self.cohort_object['who_stage_2_lymphocyte'],
							self.cohort_object['child_patients'],
							self.cohort_object['breastfeeding_mothers'],
							self.cohort_object['started_cause_pregnant'],
							self.cohort_object['who_stage_3'],
							self.cohort_object['who_stage_4'],
							self.cohort_object['start_reason_other']
				 		 ]
		return self.feed_values(validation_rule.expr, values)
	end

			  
end

