require "sinatra"
require "sinatra/activerecord"
require "pdf-reader"
require "sass"

set :database, { adapter: 'postgresql', database: 'coding_challenge', encoding: 'unicode', pool: 2 }

Dir["#{Dir.pwd}/models/*.rb"].each { |file| require file }

get "/styles.css" do
    sass :styles
end

get '/' do
    haml :new
end

post '/text_analyses' do
    file_params = params[:text_file]

    if file_params.nil?
        redirect to("/")
    else
        file = file_params[:tempfile]
        file_name = file_params[:filename]
        file_type = file_params[:type]
        exclude_stopwords = params[:exclude_stopwords] == "on" ? true : false

        text_analysis = TextAnalysis.create({ file_name: file_name, file_content: get_file_content(file, file_type), frequencies: {}, exclude_stopwords: exclude_stopwords })

        TextAnalysis.order(created_at: :asc).first.destroy if TextAnalysis.count > 10

        redirect to("/text_analyses/#{text_analysis.id}")
    end
end

get '/text_analyses/:id' do
    @text_analysis = TextAnalysis.find_by_id(params[:id])

    if @text_analysis
        haml :show
    else
        redirect to("/")
    end
end

get '/text_analyses' do
    @text_analyses = TextAnalysis.order(created_at: :asc)
    haml :index
end

private
def get_file_content(file, file_type)
    if file_type.match?(/pdf\z/)
        pdf_text(file)
    elsif file_type.match?(/plain\z/)
        file.read
    else
        nil
    end
end

def pdf_text(file)
    location = file.path
    text = ""

    PDF::Reader.new(location).pages.each do |page|
        text += page.text + "\n"
    end

    text.split.join(" ")
end

helpers do
  def partial(page, locals={})
    haml page, locals.merge!(:layout => false)
  end
end
