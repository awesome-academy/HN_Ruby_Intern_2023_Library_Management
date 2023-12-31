class JoinBooksGenres < ActiveRecord::Migration[7.0]
  def change
    create_table :book_genres do |t|
      t.belongs_to :book, null: false, foreign_key: true
      t.belongs_to :genre, null: false, foreign_key: true
      t.timestamps
    end
    add_index :book_genres, [:book_id, :genre_id], unique: true
  end
end
