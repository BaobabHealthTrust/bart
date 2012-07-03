
class Reports::PreARTReport

  def initialize(start_date, end_date)                                          
    @start_date = "#{start_date.to_date.to_s} 00:00:00"                                      
    @end_date = "#{end_date.to_date.to_s} 23:59:59"
    @cumulative_start = '1900-01-01 00:00:00'
  end 

  def total_registered(start_date = @start_date , end_date = @end_date)
    hiv_staging = EncounterType.find_by_name('HIV staging').id
    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id 
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{hiv_staging} AND e.encounter_datetime >= '#{start_date}' 
AND e.encounter_datetime <= '#{end_date}'
AND e.patient_id NOT IN(
SELECT patient_id FROM patient_registration_dates r 
WHERE r.`registration_date` >= '#{@cumulative_start}' 
AND r.`registration_date` <= '#{end_date}')
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}
  end

  def cumulative_total_registered
    total_registered(@cumulative_start,@end_date)
  end

  def quarterly_total_registered
    total_registered(@start_date,@end_date)
  end

  def quarterly_total_patients_enrolled_first_time
    ids = quarterly_total_registered.collect{|p|p.id}
    art_initiation = EncounterType.find_by_name('HIV First visit').id
    ever_registered = Concept.find_by_name('Ever registered at ART clinic').id
    no_concept = Concept.find_by_name('NO').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{art_initiation} AND e.encounter_datetime >= '#{@start_date}' 
AND e.encounter_datetime <= '#{@end_date}' AND obs.concept_id = #{ever_registered}
AND e.patient_id IN(#{ids.join(',')}) AND obs.value_coded = #{no_concept}
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}
  end


  def cumulative_total_patients_enrolled_first_time
    ids = cumulative_total_registered.collect{|p|p.id}
    art_initiation = EncounterType.find_by_name('HIV First visit').id
    ever_registered = Concept.find_by_name('Ever registered at ART clinic').id
    no_concept = Concept.find_by_name('NO').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{art_initiation} AND e.encounter_datetime >= '#{@cumulative_start}' 
AND e.encounter_datetime <= '#{@end_date}' AND obs.concept_id = #{ever_registered}
AND e.patient_id IN(#{ids.join(',')}) AND obs.value_coded = #{no_concept}
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}
  end

  def quarterly_total_patients_re_enrolled
    ids = quarterly_total_registered.collect{|p|p.id}
    art_initiation = EncounterType.find_by_name('HIV First visit').id
    ever_registered = Concept.find_by_name('Ever registered at ART clinic').id
    yes_concept = Concept.find_by_name('YES').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{art_initiation} AND e.encounter_datetime >= '#{@start_date}' 
AND e.encounter_datetime <= '#{@end_date}' AND obs.concept_id = #{ever_registered}
AND e.patient_id IN(#{ids.join(',')}) AND obs.value_coded = #{yes_concept}
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}
  end


  def cumulative_total_patients_re_enrolled
    ids = cumulative_total_registered.collect{|p|p.id}
    art_initiation = EncounterType.find_by_name('HIV First visit').id
    ever_registered = Concept.find_by_name('Ever registered at ART clinic').id
    yes_concept = Concept.find_by_name('YES').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{art_initiation} AND e.encounter_datetime >= '#{@cumulative_start}' 
AND e.encounter_datetime <= '#{@end_date}' AND obs.concept_id = #{ever_registered}
AND e.patient_id IN(#{ids.join(',')}) AND obs.value_coded = #{yes_concept}
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}
  end


  def quarterly_total_registered_males
    quarterly_total_registered.collect{|p|p if p.gender == 'Male'}.compact rescue []
  end
  
  def cumulative_total_registered_males
    cumulative_total_registered.collect{|p|p if p.gender == 'Male'}.compact rescue []
  end
  
  def quarterly_total_registered_females
    quarterly_total_registered.collect{|p|p if p.gender == 'Female'}.compact rescue []
  end
  
  def cumulative_total_registered_females
    cumulative_total_registered.collect{|p|p if p.gender == 'Female'}.compact rescue []
  end

  def quarterly_pregnant_females
    ids = quarterly_total_registered_females.collect{|p|p.id if p.gender == 'Female'}.compact rescue []
    pregnant_concept = Concept.find_by_name('Pregnant').id
    yes_concept = Concept.find_by_name('YES').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN obs ON obs.patient_id = p.patient_id WHERE obs.voided=0 
AND concept_id = #{pregnant_concept} AND obs_datetime >= '#{@start_date}' 
AND obs_datetime <= '#{@end_date}' AND obs.patient_id IN(#{ids.join(',')}) 
AND obs.value_coded = #{yes_concept} GROUP BY obs.patient_id
ORDER BY MAX(obs_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}

  end
  
  def cumulative_pregnant_females
    ids = cumulative_total_registered_females.collect{|p|p.id if p.gender == 'Female'}.compact rescue []
    pregnant_concept = Concept.find_by_name('Pregnant').id
    yes_concept = Concept.find_by_name('YES').id

    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.* FROM patient p 
INNER JOIN obs ON obs.patient_id = p.patient_id WHERE obs.voided=0 
AND concept_id = #{pregnant_concept} AND obs_datetime >= '#{@cumulative_start}' 
AND obs_datetime <= '#{@end_date}' AND obs.patient_id IN(#{ids.join(',')}) 
AND obs.value_coded = #{yes_concept} GROUP BY obs.patient_id
ORDER BY MAX(obs_datetime) DESC
EOF

    results.collect{|p|Patient.find(p['patient_id'])}

  end
  
  def quarterly_non_pregnant_females
    (quarterly_total_registered_females - quarterly_pregnant_females)    
  end
  
  def cumulative_non_pregnant_females
    (cumulative_total_registered_females - cumulative_pregnant_females)    
  end
  
  def age_at_initiation(age = '15 years', start_date = @start_date , end_date = @end_date)
    hiv_staging = EncounterType.find_by_name('HIV staging').id
    results = ActiveRecord::Base.connection.select_all <<EOF
SELECT p.*,age(p.birthdate,DATE(e.encounter_datetime),DATE(p.date_created),p.birthdate_estimated) 
AS age_at_initiation FROM patient p 
INNER JOIN encounter e ON p.patient_id = e.patient_id 
INNER JOIN obs ON e.encounter_id = obs.encounter_id WHERE obs.voided=0 
AND encounter_type = #{hiv_staging} AND e.encounter_datetime >= '#{start_date}' 
AND e.encounter_datetime <= '#{end_date}'
AND e.patient_id NOT IN(
SELECT patient_id FROM patient_registration_dates r 
WHERE r.`registration_date` >= '#{@cumulative_start}' 
AND r.`registration_date` <= '#{end_date}')
GROUP BY e.patient_id
ORDER BY MAX(e.encounter_datetime) DESC
EOF


    if age == "15 years"
      results.collect{|p|
        age_at_initiation = p['age_at_initiation'].to_i
        next if age_at_initiation < 15
        Patient.find(p['patient_id']) 
      }.compact
    elsif age == "24 months - 14yrs"
      results.collect{|p|
        age_at_initiation = p['age_at_initiation'].to_i
        next if not age_at_initiation >= 2 and not age_at_initiation < 15
        Patient.find(p['patient_id']) 
      }.compact
    elsif age == "2 months - 24 months"
      results.collect{|p|
        age_at_initiation = p['age_at_initiation'].to_i
        next if not age_at_initiation >= 2 and not age_at_initiation < 15
        Patient.find(p['patient_id']) 
      }.compact
    else
      []
    end
  end
  

end
