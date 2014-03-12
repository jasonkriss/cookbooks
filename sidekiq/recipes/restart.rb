node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping sidekiq::restart application #{application} as it is not a rails app")
    next
  end

  execute "restart-sidekiq" do
    command "monit restart all -g #{application}_sidekiq"
  end
end
