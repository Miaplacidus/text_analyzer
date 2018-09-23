require "active_record"

class TextAnalysis < ActiveRecord::Base
    validates :file_name, :file_content, presence: true
    after_validation :calculate_frequencies
    after_save :limit_text_analysis_records

    private

    def limit_text_analysis_records
        num_records = TextAnalysis.count
        if num_records > 10
            TextAnalysis.order(created_at: :asc).first.delete
        end
    end

    def limit_num_frequencies
        limited_frequencies = {}
        frequency_values = frequencies.values.sort.reverse[0..24]

        frequencies.each do |word, count|
            if frequency_values.include?(count)
                limited_frequencies[word] = count
                frequency_values.delete_at(frequency_values.find_index(count))
            end
            break if frequency_values.empty?
        end

        self.frequencies = limited_frequencies
    end

    def is_stopword?(word)
        StopWords::WORDS.include?(word)
    end

    def calculate_frequencies
        file_content.split(/[^a-zA-Z0-9_']+/).each do |word|
            next if (exclude_stopwords? && is_stopword?(word))

            word.downcase!

            stem =
            case
            when word.match(/(\w+)(ies\z)/)
                ies_case($1)
            when word.match(/(\w+)(oes\z)/)
                oes_case($1)
            when word.match(/(\w+)(ves\z)/)
                ves_case($1)
            when word.match(/(\w+)(es\z)/)
                es_case($1)
            when word.match(/(\w+)(ied\z)/)
                ied_case($1)
            when word.match(/(\w+)(ed\z)/)
                ed_case($1)
            when word.match(/(\w+)(ing\z)/)
                ing_case($1)
            when word.match(/(\w+)(s\z)/)
                word.chop
            else
                word
            end

            if frequencies.key?(stem)
                frequencies[stem] += 1
            else
                frequencies[stem] = 1
            end
        end

        limit_num_frequencies
    end

    def ies_case(pre_match)
        pre_match + "y"
    end

    def oes_case(pre_match)
        pre_match + "o"
    end

    def ves_case(pre_match)
        pre_match + "f"
    end

    def es_case(pre_match)
        if sibilant_ending?(pre_match) || non_e_vowel_ending?(pre_match)
            pre_match
        else
            pre_match + "e"
        end
    end

    def ied_case(pre_match)
        pre_match + "y"
    end

    def ed_case(pre_match)
        if (non_e_vowel_ending?(pre_match) || consonant_ending?(pre_match)) && !doubled_consonant_ending?(pre_match)
            pre_match
        elsif doubled_consonant_ending?(pre_match)
            pre_match.chop
        else
            pre_match + "e"
        end
    end

    def ing_case(pre_match)
        if doubled_consonant_ending?(pre_match) || ck_ending?(pre_match)
            pre_match.chop
        elsif likely_silent_e?(pre_match)
            pre_match + "e"
        else
            pre_match
        end
    end

# WORD ENDINGS
    def sibilant_ending?(word)
        word.match?(/(s|z|sh|ch|x)\z/)
    end

    def non_e_vowel_ending?(word)
        word.match?(/[aeiou]\z/)
    end

    def consonant_ending?(word)
        word.match?(/[^aeiou]\z/)
    end

    def doubled_consonant_ending?(word)
        word.match?(/([^aeiouy])\1+\z/)
    end

    def vowel_consonant_ending?(word)
        word.match?(/[aeiouy][^aeiouy]\z/)
    end

    def likely_one_syllable?(word)
        word.scan(/[aeiouy]/).count == 1
    end

    def likely_silent_e?(word)
        vowel_consonant_ending?(word) && likely_one_syllable?(word)
    end

    def ck_ending?(word)
        word.match?(/ck\z/)
    end
end
