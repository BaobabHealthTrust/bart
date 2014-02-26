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
		  
end

