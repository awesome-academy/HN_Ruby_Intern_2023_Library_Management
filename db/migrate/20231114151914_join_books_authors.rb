class JoinBooksAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :book_authors do |t|
      t.belongs_to :book, null: false, foreign_key: true
      t.belongs_to :author, null: false, foreign_key: true

      t.timestamps
    end
    add_index :book_authors, [:book_id, :author_id], unique: true
  end
end
