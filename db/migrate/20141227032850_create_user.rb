class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :hashed_password
      t.string :auth_token
      t.string :alias
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
    end
  end
end
