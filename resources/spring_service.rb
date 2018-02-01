actions :default
default_action :default

property :artifact_directory,  :kind_of => String, :required => true
property :artifact, :kind_of => String, :required => true
property :service_name, :name_attribute => true, :kind_of => String, :required => true

property :jar_file, :kind_of => String, :required => false
property :log_folder, :kind_of => String, :required => false
property :run_args, :kind_of => String, :required => false
property :java_opts, :kind_of => String, :required => false
property :log_filename, :kind_of => String, :required => false

property :mode, :kind_of => Integer, :required => false, default: 755
property :user, :kind_of => String, :required => false, default: 'root'
property :service_type, :kind_of => String, :required => false

resource_name 'spring_service'

action :default do

  type = new_resource.service_type
  if type.nil? then
    if ::File.directory?('/usr/lib/systemd') then
      type = 'systemd'
    elsif ::File.directory?('/etc/init.d') then
      type = 'init.d'
    end
  end


  if type == 'init.d' then
    link "#{new_resource.artifact_directory}/#{new_resource.artifact}" do
      to "/etc/init.d/#{new_resource.service_name}"
      link_type :symbolic
      mode new_resource.mode
    end
  elsif type == 'systemd' then
    template "/etc/systemd/system/#{new_resource.service_name}.service" do
      source 'systemd.service.erb'
      mode new_resource.mode
      variables({
        :desc => "#{new_resource.artifact} service script",
        :user => user,
        :exec_start => "#{new_resource.artifact_directory}/#{new_resource.artifact}"
      })
    end
  else
    raise "Unrecognized service type: #{type}"
  end

  template "#{new_resource.artifact_directory}/#{new_resource.service_name}.conf" do
    source 'artifact.conf.erb'
    mode new_resource.mode
    variables({
      :jar_file => new_resource.jar_file,
      :log_folder => new_resource.log_folder,
      :run_args => new_resource.run_args,
      :java_opts => new_resource.java_opts,
      :log_filename => new_resource.log_filename
    })
  end

  service new_resource.artifact do
    action :start
  end
end
