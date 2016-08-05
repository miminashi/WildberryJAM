class AddSshKey < ActiveRecord::Migration
  def change
    add_column :connections, :ssh_private_key, :string
    add_column :connections, :ssh_public_key, :string
  end
end
