require_relative "../models/text_analysis.rb"
require_relative "./shared_examples.rb"
require File.expand_path '../spec_helper.rb', __FILE__

describe TextAnalysis do
    context "including common stopwords" do
        include_examples "text_analysis", false
    end

    context "excluding stop words" do
        include_examples "text_analysis", true
    end
end
