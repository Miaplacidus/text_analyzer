class CreateTextAnalyses < ActiveRecord::Migration[5.2]
  def change
      create_table :text_analyses do |t|
          t.string :file_name
          t.boolean :exclude_stop_words, default: true
          t.text :file_content
          t.jsonb :frequencies, default: {}
          t.timestamps
      end
  end
end
