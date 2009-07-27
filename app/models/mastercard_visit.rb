class MastercardVisit

  attr_accessor :date, :weight, :height, :bmi, :outcome, :reg, :s_eff, :sk , :pn, :hp, :pills, :gave, :cpt, :cd4,:estimated_date,:next_app, :tb_status, :doses_missed, :visit_by, :date_of_outcome, :reg_type, :adherence, :patient_visits


  def self.visit(patient,date = Date.today)
    visits = self.new()
    symptoms = []
    remaining_pills = []
    concept_names = Concept.find_by_name('Symptoms').answer_options.collect{|option| option.name}
    concept_names += Concept.find_by_name('Symptoms continued..').answer_options.collect{|option| option.name}
    concept_names+= ["Weight","Height","Prescribe Cotrimoxazole (CPT)","Hepatitis","Peripheral neuropathy"]
      concept_names.each{|concept_name|
      observations = Observation.find(:all,:conditions => ["voided = 0 and Date(obs_datetime)='#{date}' and concept_id=? and patient_id=?",(Concept.find_by_name(concept_name).id),patient.patient_id],:order=>"obs.obs_datetime desc")
      observations.each{|observation|
      case concept_name
        when "Weight"
          visits.weight=observation.value_numeric 
        when "Height"
          visits.height = observation.value_numeric 
        when "Prescribe Cotrimoxazole (CPT)"
          pills_given=patient.drug_orders_for_date(observation.obs_datetime)
          if pills_given
            pills_given.each{|names|
            if names.drug.name=="Cotrimoxazole 480"
              visits.cpt = names.quantity # observation.result_to_string
            end
            }
          end
        else
          unless observation.blank?
            ans = observation.answer_concept.name 
            next if ans != "Yes drug induced"
            symptoms << observation.concept.short_name rescue nil
          end
        end
      }

    }


    #the following code pull out the number of tablets given to a patient per visit
    number_of_pills_given = self.drugs_given(patient,date)
    unless  number_of_pills_given.blank?
      visits.reg = number_of_pills_given.map{|reg_type,drug_quantity_given|drugs_quantity = drug_quantity_given.split(":")[1]
                                        drugs_quantity.split(";").collect{|x|x}}.compact.uniq.first
      
      drugs_given_to_patient =  patient.patient_present?(date)
      drugs_given_to_guardian =  patient.guardian_present?(date)
      drugs_given_to_both_patient_and_guardian =  patient.patient_and_guardian_present?(date)
      visits.reg_type = number_of_pills_given.collect{|type,values|type}.to_s rescue nil

      visits.visit_by = "Guardian visit" if drugs_given_to_guardian
      visits.visit_by = "Patient visit" if drugs_given_to_patient
      visits.visit_by = "Pat & Grdn visit" if drugs_given_to_both_patient_and_guardian
    end
         
          
    visits.height = patient.current_height if visits.height.blank?
    unless visits.height.blank? and visits.weight.blank? then
      bmi=(visits.weight.to_f/(visits.height.to_f**2)*10000)
      visits.bmi = sprintf("%.1f", bmi)
    end

    visits.tb_status = self.outcome_tb_status(patient.tb_status(date))
    visits.adherence = patient.adherence(date)
    visits.next_app = patient.next_appointment_date(date)
    visits.cpt = 0 if visits.cpt.blank?
    visits.outcome = self.outcome_abb(patient.outcome(date).name) rescue nil
    visits.date_of_outcome = patient.outcome_date(date) if visits.outcome == "Died"  
    symptoms.collect{|side_eff|if visits.s_eff.blank? then visits.s_eff = side_eff.to_s else visits.s_eff+= "," + side_eff.to_s end} 
    visits.s_eff = "None" if visits.s_eff.blank?

    visits
  end

  def self.outcome_tb_status(tb_status)
   case tb_status
     when "Confirmed TB not on treatment"
       return "noRx"
     when "Confirmed TB on treatment"
       return "Rx"
     when "TB suspected" 
       return "susp"
     when "Unknown"
       return "unk"
     else
       return "None"
    end
  end

  def self.outcome_abb(outcome)
   case outcome
     when "Defaulter"
       return "Def"
     when "Transfer Out"
       return "TO"
     when "Transfer Out(With Transfer Note)" 
       return "Transfer Out"
     when "Transfer Out(Without Transfer Note)"
       return "Transfer Out"
     when "ART Stop"
       return "Stop"
     when "Died"
       return "Died"
     else
       return "Alve"
    end
  end

  def self.drugs_given(patient,date)
    patient_regimems = PatientHistoricalRegimen.find_by_sql("select * from (select * from patient_historical_regimens where                 patient_id=#{patient.id} and date(dispensed_date)='#{date}' order by dispensed_date desc) as regimen group by regimen_concept_id")
    regimen_name = patient_regimems.first.concept.concept_sets.first.name rescue nil
    return nil if regimen_name.blank?
    
    start_dates = {}
   #the following code pull out the number of tablets given to a patient per visit
   number_of_pills_given = patient.drugs_given_last_time(date)
   unless  number_of_pills_given.blank?
     total_quantity_given = Hash.new(0)
     number_of_pills_given.each do |drug,quantity|
       name = drug.short_name 
       total_quantity_given[name]+= quantity
     end
     
     total_quantity_given.each{|drug,quantity|  
       start_dates[regimen_name]+=";#{drug} (#{quantity})" unless start_dates[regimen_name].blank?
       start_dates[regimen_name]="#{date.to_date.to_s}:#{drug} (#{quantity})" if start_dates[regimen_name].blank?
     }
   end
   start_dates
  end

  def self.demographics(patient_obj)
    visits = PatientMastercard.new()
    visits.patient_id = patient_obj.id
    visits.arv_number = patient_obj.ARV_national_id
    visits.national_id = patient_obj.print_national_id
    visits.name = patient_obj.name
    visits.age =patient_obj.age
    visits.sex = patient_obj.gender
    visits.init_wt = patient_obj.initial_weight
    visits.init_ht = patient_obj.initial_height
    bmi=(visits.init_wt/(visits.init_ht**2)*10000) rescue nil 
    visits.bmi = sprintf("%.1f", bmi) rescue nil
    visits.transfer =  patient_obj.transfer_in? ? "Yes" : "No"
    visits.address = patient_obj.physical_address 
    visits.landmark = patient_obj.patient_location_landmark 
    visits.occupation = patient_obj.occupation
    visits.guardian = "#{patient_obj.art_guardian.name rescue 'None'} #{'(' + patient_obj.art_guardian_type.name + ')' rescue nil}" 
    visits.agrees_to_followup = patient_obj.requested_observation("Agrees to followup")
    visits.hiv_test_location = patient_obj.place_of_first_hiv_test
    visits.hiv_test_date = patient_obj.hiv_test_date

    visits.reason_for_art =  patient_obj.reason_for_art_eligibility.name rescue nil   
    visits.ptb = patient_obj.requested_observation("Pulmonary tuberculosis within the last 2 years")
    visits.extr_tuberculosis = patient_obj.requested_observation("Extrapulmonary tuberculosis")
    visits.ks = patient_obj.requested_observation("Kaposi's sarcoma")
    visits.active_pulmonary_tb = patient_obj.requested_observation("Pulmonary tuberculosis (current)")
    visits.referred_by_pmtct = patient_obj.requested_observation("Referred by PMTCT")
    visits.date_started_art = patient_obj.date_started_art.strftime("%d-%b-%Y") rescue nil
    visits.patient_visits = {}
    visits
  end

  def self.visits(patient_obj)
    patient_visits = {}
    concept_names = Concept.find_by_name('Symptoms').answer_options.collect{|option| option.name}
    concept_names += Concept.find_by_name('Symptoms continued..').answer_options.collect{|option| option.name}
    concept_names +=["Weight","Height","Prescribe Cotrimoxazole (CPT)","Whole tablets remaining and brought to clinic","ARV regimen","Outcome"]
    
    concept_names.each{|concept_name|
    
      patient_observations = Observation.find(:all,:conditions => ["voided = 0 and concept_id=? and patient_id=?",(Concept.find_by_name(concept_name).id),patient_obj.patient_id],:order=>"obs.obs_datetime desc")

      patient_observations.each{|obs|

        next if obs.nil? or obs.encounter.nil?
        next if obs.encounter.name == "HIV First visit" rescue nil # added "rescue nil" @ salima..  ask the team!!

        visit_date = obs.obs_datetime.to_date

        patient_visits[visit_date] = self.new() if patient_visits[visit_date].blank?
        case concept_name
          when "Weight"
               patient_visits[visit_date].weight=obs.value_numeric unless obs.nil?

          when "Height"
            patient_visits[visit_date].height = obs.value_numeric unless obs.nil?
            if patient_obj.age > 18 and !patient_obj.observations.find_last_by_concept_name("Height").nil?
              patient_visits[visit_date].height=patient_obj.observations.find_last_by_concept_name("Height").value_numeric 
            end  
            unless patient_visits[visit_date].height.nil? and patient_visits[visit_date].weight.nil? then 
              bmi=(patient_visits[visit_date].weight.to_f/(patient_visits[visit_date].height.to_f**2)*10000)
              patient_visits[visit_date].bmi =sprintf("%.1f", bmi)
            end
          when "Prescribe Cotrimoxazole (CPT)"
            pills_given=patient_obj.drug_orders_for_date(obs.obs_datetime)
            if pills_given
              pills_given.each{|names|
                if names.drug.name=="Cotrimoxazole 480"
                  patient_visits[visit_date].cpt = obs.result_to_string
                end
              }
            end
          when "Whole tablets remaining and brought to clinic"
            unless  patient_observations.nil?
              pills_left= obs.value_numeric
              pills_left=pills_left.to_i unless pills_left.nil? and !pills_left.to_s.strip[-2..-1]==".0"
              if pills_left !=0
                if patient_visits[visit_date].pills.nil?
                  patient_visits[visit_date].pills= "#{obs.drug.short_name + ' ' if obs.drug } #{pills_left.to_s}" unless pills_left.nil?
                else
                  patient_visits[visit_date].pills+= "<br/>" +  "#{obs.drug.short_name + ' ' if obs.drug } #{pills_left.to_s}" unless pills_left.nil?
                end
              end
            end
=begin
          when "Whole tablets remaining but not brought to clinic"
            unless  patient_observations.nil?
               pills_left= obs.value_numeric
               pills_left=pills_left.to_i unless pills_left.nil? and !pills_left.to_s.strip[-2..-1]==".0"
               if pills_left !=0
                 if patient_visits[visit_date].pills.nil?
                   patient_visits[visit_date].pills= "#{obs.drug.short_name + ' ' if obs.drug } #{pills_left.to_s}" unless pills_left.nil?
                 else
                   patient_visits[visit_date].pills+= "<br/>" + "#{obs.drug.short_name + ' ' if obs.drug } #{pills_left.to_s}" unless pills_left.nil?
                 end 
               else
                   patient_visits[visit_date].pills="No pills left" if patient_visits[visit_date].pills.nil?   
               end
            end
          when "CD4 count"
            unless  patient_observations.nil?
              value_modifier = obs.value_modifier
              if value_modifier.blank? || value_modifier == ""
                cd_4 = obs.value_numeric
                cd_4 = "Unknown" if obs.value_numeric == 0.0
                patient_visits[visit_date].cd4 = cd_4
              else
                patient_visits[visit_date].cd4 = value_modifier + obs.value_numeric.to_s
              end  
            end   
          when "CD4 percentage"
            next unless patient_visits[visit_date].cd4.blank? and patient_obj.child?
            unless  patient_observations.nil?
              value_modifier = obs.value_modifier
              if value_modifier.blank? || value_modifier == ""
                cd_4 = obs.value_numeric
                cd_4 = "Unknown" if obs.value_numeric == 0.0
                patient_visits[visit_date].cd4 = "#{cd_4}%"
              else
                patient_visits[visit_date].cd4 = "#{value_modifier}#{obs.value_numeric}%"
              end  
            end   
=end            
          when "Outcome" 
            patient_visits[visit_date].outcome = patient_obj.cohort_outcome_status(visit_date,visit_date)
          else
            unless obs.blank?
              ans = obs.answer_concept.name 
              side_effect = obs.concept.short_name
              next if ans != "Yes drug induced"
              unless patient_visits[visit_date].s_eff.nil?
                patient_visits[visit_date].s_eff+= "</p>" + side_effect
              else
                patient_visits[visit_date].s_eff = side_effect
              end
            end
          end 

          patient_visits[visit_date].tb_status = self.outcome_tb_status(patient_obj.tb_status(visit_date))
          patient_visits[visit_date].adherence = patient_obj.adherence(visit_date)
        }
    }
               
    patient_visits.keys.each{|date|
      number_of_pills_given = patient_obj.drugs_given_last_time(date)
      number_of_pills_given = self.drugs_given(patient_obj,date)
      unless  number_of_pills_given.blank?
        number_of_pills_given.map{|reg_type,drug_quantity_given|
            drugs_quantity = drug_quantity_given.split(":")[1]
            patient_visits[date].gave = drugs_quantity.split(";").join("</br>")
            reg = []
            drugs_quantity.split(";").each{|x|reg << x.gsub(/\s[^\s]*$/, "")}
            patient_visits[date].reg = reg.join("</br>")
          }.compact.uniq.first

        gave = "P</br>" +  patient_visits[date].gave if patient_obj.patient_present?(date)
        gave = "G</br>" +  patient_visits[date].gave if  patient_obj.guardian_present?(date)
        gave = "PG</br>" +  patient_visits[date].gave if patient_obj.patient_and_guardian_present?(date)
        patient_visits[date].gave = gave if gave
        patient_visits[date].reg_type = number_of_pills_given.collect{|type,values|type}.to_s rescue nil
      end     
    }

    show_cd4_trail = GlobalProperty.find_by_property("show_lab_trail").property_value rescue "false"
    if show_cd4_trail == "true"
      test_types = LabTestType.find(:all,:conditions=>["(TestName=? or TestName=?)",
                             "CD4_count","CD4_percent"]).map{|type|type.TestType} rescue [] if show_cd4_trail == "true"
      available_cd4_tests = patient_obj.detail_lab_results("CD4") rescue {}
      cd4_results = {}
      available_cd4_tests.each{|date,results|
        visit_date = date.to_date
        results.each{|result|
          case result.TESTTYPE
            when test_types.first
              cd4_results[visit_date] = {"CD4 count" => "#{result.Range rescue nil} #{result.TESTVALUE rescue nil}"} if  cd4_results[visit_date].blank?
             cd4_results[visit_date]["CD4 count"] = "#{result.Range rescue nil} #{result.TESTVALUE rescue nil}" unless  cd4_results[visit_date].blank?
            else
              cd4_results[visit_date] = {"CD4 percentage" => "#{result.Range rescue nil} #{result.TESTVALUE.to_s + "%" rescue nil}"} if  cd4_results[visit_date].blank?
              cd4_results[visit_date]["CD4 percentage"] = "#{result.Range rescue nil} #{result.TESTVALUE.to_s + "%" rescue nil}" unless  cd4_results[visit_date].blank?
            end
        } 
      } unless available_cd4_tests.blank?

      cd4_results.each{|date,results|
        visit_date = date.to_date
        patient_visits[date] = self.new() if patient_visits[date].blank?
        result = cd4_results[date]["CD4 percentage"] if patient_obj.child? and !cd4_results[date]["CD4 percentage"].blank?
        result = cd4_results[date]["CD4 count"] if result.blank?
        patient_visits[date].cd4 = result
      }
    end
    patient_visits
  end

  def self.next_mastercard(current_patient,patient_ids,next_previous="next_card")
    patient_visits_hash = {}
    count = 1
    patient_ids.each{|id|
      patient_visits_hash[id]=count
      count+=1
    }

    #return patient_visits_hash
    current_count = patient_visits_hash.indexes(current_patient)[0].to_i

    if next_previous == "next_card"
      next_patient_id = patient_visits_hash.index(current_count+1) if current_count < patient_ids.length  rescue nil
      next_patient_id = patient_visits_hash.index(patient_ids.length - (current_count - 1)) if current_count == patient_ids.length  rescue nil
    else
      next_patient_id =  patient_visits_hash.index(current_count - 1) if current_count > 1  rescue nil
      next_patient_id =  patient_visits_hash.index(patient_ids.length) if current_count == 1  rescue nil
    end
    next_patient_id
  end

end
