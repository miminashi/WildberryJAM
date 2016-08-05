class AddProxyProcessPid < ActiveRecord::Migration
  def change
    add_column :connections, :proxy_process_pid, :integer
  end
end
