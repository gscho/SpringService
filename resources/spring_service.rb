actions :default
default_action :default

property :artifact_directory, :name_attribute => false, :kind_of => String, :required => true
property :artifact, :name_attribute => false, :kind_of => String, :required => true

property :jar_file, :name_attribute => false, :kind_of => String, :required => false
property :log_folder, :name_attribute => false, :kind_of => String, :required => false
property :run_args, :name_attribute => false, :kind_of => String, :required => false
property :java_opts, :name_attribute => false, :kind_of => String, :required => false
property :log_filename, :name_attribute => false, :kind_of => String, :required => false, :default => "#{artifact}.log"

property :mode, :name_attribute => false, :kind_of => Integer, :required => false
property :user, :name_attribute => false, :kind_of => String, :required => false
property :service_type, :name_attribute => false, :kind_of => String, :required => false

resource_name 'spring_service'

action :default do

  artifact_name = ::File.basename(artifact, ::File.extname(artifact))

  if service_type.nil? then
    if ::File.directory?('/usr/lib/systemd') then
      service_type = 'systemd'
    elsif ::File.directory?('/etc/init.d') then
      service_type = 'init.d'
    end
  end

  user = user.nil? ? 'root' : user
  mode = mode.nil? ? 755 : mode

  if service_type == 'init.d' then
    link "#{artifact_directory}/#{artifact}" do
      to "/etc/init.d/#{artifact_name}"
      link_type :symbolic
      mode mode
    end
  elsif service_type == 'systemd' then
    template "/etc/systemd/system/#{artifact_name}.service" do
      source 'systemd.service.erb'
      mode mode
      variables({
        :desc => "#{artifact} service script",
        :user => user,
        :exec_start => "#{artifact_directory}/#{artifact}"
      })
    end
  else
    raise "Unrecognized service type: #{service_type}"
  end

  template "#{artifact_directory}/#{artifact_name}.conf" do
    source 'artifact.conf.erb'
    mode mode
    variables({
      :jar_file => jar_file,
      :log_folder => log_folder,
      :run_args => run_args,
      :java_opts => java_opts,
      :log_filename => log_filename
    })
  end

  service artifact do
    action :start
  end
end
