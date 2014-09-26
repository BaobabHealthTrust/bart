
  @@separator = '-'

  # we are taking out letters B, I, O, Q, S, Z because they might be
  # mistaken for 8, 1, 0, 0, 5, 2 respectively
  @@base_map = ['0','1','2','3','4','5','6','7','8','9','A','C','D','E','F','G',
                'H','J','K','L','M','N','P','R','T','U','V','W','X','Y']
              
  @@reverse_map = {'0' => 0,'1' => 1,'2' => 2,'3' => 3,'4' => 4,'5' => 5,
                   '6' => 6,'7' => 7,'8' => 8,'9' => 9,
                   'A' => 10,'C' => 11,'D' => 12,'E' => 13,'F' => 14,'G' => 15,
                   'H' => 16,'J' => 17,'K' => 18,'L' => 19,'M' => 20,'N' => 21,
                   'P' => 22,'R' => 23,'T' => 24,'U' => 25,'V' => 26,'W' => 27,
                   'X' => 28,'Y' => 29}

  # @author: Mike Mckay
  # Calculate a check digit using Luhn's Algorithm as implemented in BART
  # http://en.wikipedia.org/wiki/Luhn_algorithm
  # PatientIdentifier.calculate_checkdigit
  def check_digit(number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    # Same algorithm used by PIH (except they allow characters)
    number = number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2==parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    checkdigit = 0
    checkdigit = checkdigit +1 while ((sum+(checkdigit))%10)!=0
    checkdigit
  end

  # Convert a Base 10 <tt>number</tt> to the specified <tt>base</tt>
  def convert(num)
    results = ''
    quotient = num.to_i

    @base = 30 if @base.blank?
 
    while quotient > 0 
      results = @@base_map[quotient % @base] + results
      quotient = (quotient / @base)
    end
    results
  end

  # When converting to string, print a hyphen after the third character
  def to_s
    "#{@value.slice(0,3)}#{@@separator}#{@value.slice(3,@value.length)}"
  end

  # Convert given <tt>num</tt> in from the specified <tt>from_base</tt> to
  # decimal (base 10)
  def to_decimal(num, from_base=30)
    decimal = 0
    num.to_s.gsub(@@separator, '').split('').reverse.each_with_index do |n, i|
      decimal += @@reverse_map[n] * (from_base ** i) rescue 0
    end
    decimal
  end

  # Checks if <tt>num<tt> has a correct check digit
  def valid?(num)
    core_id = num / 10
    check_digit = num % 10 # last digit

    check_digit == check_digit(core_id)
  end


  def start
    unassigned_ids = PatientNationalId.find(:all,:conditions =>["assigned = 1 AND LENGTH(value) = 6"])
    none_valid_ids = []
    (unassigned_ids || []).each do |national_identifier|
      num = to_decimal(national_identifier.value)
      unless valid?(num)
        none_valid_ids << national_identifier
      end
    end

    unless none_valid_ids.blank?
      ids = []
      `touch #{RAILS_ROOT}/delete_invalid_ids.txt`
      (none_valid_ids).each do |v|
        `cat #{v.value} >> #{RAILS_ROOT}/delete_invalid_ids.txt`
        ids << v.id
      end


      ActiveRecord::Base.connection.execute <<EOF
      DELETE FROM patient_national_id WHERE id IN(#{ids.join(',')});
EOF

      puts "Deleted #{ids.length} invalid v4 national identifiers"
    end

  end

start
