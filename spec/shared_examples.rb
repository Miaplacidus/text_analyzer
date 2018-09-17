RSpec.shared_examples "text_analysis" do |exclude_stop_words|
  let(:text_analysis_attrs){{
      file_name: "test_file.txt",
      frequencies: {},
      exclude_stop_words: exclude_stop_words
  }}

  let(:file_content){
      "cries cry scurry scurries them tree fries goes tomato tree do hero tomatoes tree does hero foes heroes foe foe wolf were wolves love tree leaves isn't loves leaf fizz fizzes tree mix were wash mixes washes harry were tree harried isn't foes clarified clarify very hoped to hope tree play played loves laugh who laughed laugh tree to laughing play i've them carry played hop carrying playing hopped love were them hopping"
  }

# includes error for words "foe"/"foes", "love"/"loves", "hope"/"hoped"
  let(:freq_with_stop_words){
      {
          "cry" => 2,
          "scurry" => 2,
          "tree" => 8,
          "them" => 3,
          "tomato" => 2,
          "do" => 2,
          "fo" => 2,
          "foe" => 2,
          "hero" => 3,
          "wolf" => 2,
          "leaf" => 2,
          "lof" => 2,
          "love" => 2,
          "fizz" => 2,
          "mix" => 2,
          "wash" => 2,
          "were" => 4,
          "clarify" => 2,
          "harry" => 2,
          "isn't" => 2,
          "laugh" => 4,
          "to" => 2,
          "play" => 5,
          "carry" => 2,
          "hop" => 4,
      }
  }

  let(:freq_sans_stop_words){
      {
          "cry" => 2,
          "scurry" => 2,
          "tree" => 8,
          "fry" => 1,
          "go" => 1,
          "tomato" => 2,
          "fo" => 2,
          "foe" => 2,
          "hero" => 3,
          "wolf" => 2,
          "leaf" => 2,
          "lof" => 2,
          "love" => 2,
          "fizz" => 2,
          "mix" => 2,
          "wash" => 2,
          "clarify" => 2,
          "harry" => 2,
          "hope" => 1,
          "laugh" => 4,
          "play" => 5,
          "carry" => 2,
          "hop" => 4,
      }
  }

  it "returns the count of words with the same stem" do
      freq = exclude_stop_words ? freq_sans_stop_words : freq_with_stop_words
      text_analysis_attrs.merge!({ file_content: file_content })
      text_analysis = TextAnalysis.create(text_analysis_attrs)
      expect(text_analysis.frequencies).to eq(freq)
  end

  it "returns a maximum of 25 words" do
      freq = exclude_stop_words ? freq_sans_stop_words : freq_with_stop_words
      num_words = exclude_stop_words ? 23 : 25
      text_analysis_attrs.merge!({ file_content: file_content })
      text_analysis = TextAnalysis.create(text_analysis_attrs)
      expect(text_analysis.frequencies.size).to eq(num_words)
  end

  it "allows only the 10 most recent records" do
      seconds_in_day = 86400

      12.times do |i|
          freq = exclude_stop_words ? freq_sans_stop_words : freq_with_stop_words
          text_analysis_attrs.merge!({ file_content: file_content })
          text_analysis = TextAnalysis.create(text_analysis_attrs.merge(created_at: Time.now - (i + 1) * seconds_in_day))
      end

      expect(TextAnalysis.count).to eq(10)
      
      created_most_recently = TextAnalysis.pluck(:created_at).all?{ |time| time > Time.now - 11 * seconds_in_day}
      expect(created_most_recently).to eq(true)
  end
end
