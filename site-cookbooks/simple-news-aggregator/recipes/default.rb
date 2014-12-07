# Grab the app codes
git "#{node['app_dir']}" do
  repository "#{node['github_repo']}"
  reference "master"
  action :sync
end

# Create venv
python_virtualenv "#{node['app_dir']}"+"/venv" do
  action :create
  not_if "test -d "+"#{node['app_dir']}"+"/venv"
end

# Install pip packages
bash "Install pip packages" do
  cwd "#{node['app_dir']}"
  code <<-EOH
  source "#{node['app_dir']}"+"/venv/bin/activate"
  pip install -r requirements.txt
  EOH
end

# Run gunicorn
bash "Run gunicorn" do
  cwd "#{node['app_dir']}"
  code <<-EOH
  source "#{node['app_dir']}"+"/venv/bin/activate"	
  gunicorn -b 0.0.0.0:5000 app:app &
  EOH
end

# Create nginx default config from template
nginx_config = "#{node['nginx']['dir']}" + "/sites-available/default"
template nginx_config do
  source "nginx.conf.erb"
  mode "0644"
end



