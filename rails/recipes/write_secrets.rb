node[:deploy].each do |application, deploy|
  template "#{deploy[:deploy_to]}/shared/config/secrets.yml" do
    source "secrets.yml.erb"
    cookbook 'rails'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:secrets => deploy[:secrets], :environment => deploy[:rails_env])

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      deploy[:secrets].present? && File.directory?("#{deploy[:deploy_to]}/current/config/")
    end
  end
end
