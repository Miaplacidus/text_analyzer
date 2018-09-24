# Text Analyzer
TextAnalyzer accepts plaintext and pdf files as input and runs a frequency analysis on the words in the document. Specifically, it returns the 25 most frequently-used words in the file.

If two words have the same stem (e.g. 'go' and 'going', 'cat' and 'cats'), then they each contribute towards the count of their shared stem. The stem of a word is extracted using rules governing the conjugation and declension of verbs and nouns such as that verbs ending in 'sh' have 'es' added to get the present tense form.

## Dependencies
TextAnalyzer is a Sinatra app that uses the ActiveRecord ORM with a PostreSQL database. The [PDF::Reader gem](https://github.com/yob/pdf-reader) is used to extract the text from PDF input files.

HAML and Sass are used for templating and styling. Tests are written with the RSpec testing framework.

## Usage
To run the app locally, first execute the `bundle` command to install all of the dependencies. Then run `ruby app.rb` and go to `localhost:4567` in your browser.

## Running Specs
```
rspec spec/text_analysis_spec.rb
```
