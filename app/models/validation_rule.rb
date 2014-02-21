class ValidationRule < ActiveRecord::Base

  def self.data_consistency_checks(date = Date.today)

  end

  def self.create_update_validation_result(rule, date, result)

  end

  def self.validate_presence_of_start_reason
    #This function checks for patients who do not have a reason for starting ART


  end

  def self.dispensation_without_prescription(end_date = Date.today)
    unprescribed = Observation.find_by_sql("
                                  SELECT DISTINCT(encounter.patient_id)
                                  FROM orders
                                  INNER JOIN encounter USING(encounter_id)
                                  INNER JOIN drug_order USING(order_id)
                                  INNER JOIN drug ON drug.drug_id = drug_order.drug_inventory_id
                                  INNER JOIN concept_set ON concept_set.concept_id = drug.concept_id
                                  WHERE concept_set.concept_set = 460 AND
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
                                  AND NOT EXISTS (
                                  SELECT patient_id FROM obs
                                  WHERE concept_id = (SELECT concept_id FROM concept WHERE name = 'APPOINTMENT DATE')
                                  AND DATE(encounter_datetime) = DATE(obs_datetime)
                                  AND patient_id = encounter.patient_id)")
    return no_appointment.length
  end
end
