class MyString < String
  ALPHAS = ('a'..'z').to_a
  VOWELS = %w[a e i o u]
  CONSONANTS = ALPHAS - VOWELS
  def to_pig_latin
    words = encode("UTF-8", invalid: :replace, replace: '?').split(' ')
    result = []
    words.each do |word|
      head, tail = '', ''
      word_array = word.split('')
      until word_array.empty?
        letter = word_array.shift
        if letter && VOWELS.include?(letter.downcase)
          tail += 'ay'
          head += letter
          letter = word_array.shift
          while letter && ALPHAS.include?(letter.downcase)
            head += letter
            letter = word_array.shift
          end
          until letter.nil? || ALPHAS.include?(letter.downcase)
            tail += letter
            letter = word_array.shift
          end
          word_array.unshift(letter)
          head = head + tail
          tail = ''
        elsif letter
          tail += letter
          if letter == 'q' && word_array.first == 'u'
            tail += word_array.shift
          end
        end
      end
      result << head + tail
    end
    result.join(' ')
  end
end