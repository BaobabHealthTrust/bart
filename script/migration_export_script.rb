require 'migrator'

Thread.abort_on_exception = true

puts "Starting Exporter"

@limit = 10	#number of encounters to export per encounter_type
@export_path = '/tmp/migrator'
@patients_list = [629,189]

threads = []	#initialize an array of threads
encounter_types = [1,2,3,4,5,6,7,14,15,17]	#initialize an array of acceptable encounter_types

#action to export the individual encounters
def export_enc(type)
  puts "starting #{EncounterType.find(type).name} export"
	m = EncounterExporter.new(@export_path, type, @limit, @patients_list)
	m.to_csv
  puts "#{EncounterType.find(type).name} done"
end

encounter_types.each do |t|
  #threads << Thread.new(t) do |j|
	#	sleep(1)
		export_enc(t)
	#end
end

#threads.each {|thread| thread.join}
