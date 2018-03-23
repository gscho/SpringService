actions :default
default_action :default

property :artifact_directory, kind_of: String, required: true
property :artifact, kind_of: String, required: true
property :service_name, name_attribute: true, kind_of: String, required: true
property :jar_file, kind_of: String, required: false
property :log_folder, kind_of: String, required: false
property :run_args, kind_of: String, required: false
property :java_opts, kind_of: String, required: false
property :log_filename, kind_of: String, required: false
property :mode, kind_of: Integer, required: false, default: 755
property :user, kind_of: String, required: false, default: 'root'
property :group, kind_of: String, required: false, default: 'root'
property :service_type, kind_of: String, required: false

resource_name 'spring_service'

action :default do
  type = new_resource.service_type
  if type.nil?
    if ::File.directory?('/usr/lib/systemd')
      type = 'systemd'
    elsif ::File.directory?('/etc/init.d')
      type = 'init.d'
    end
  end

  case type
  when 'init.d'
    link "#{new_resource.artifact_directory}/#{new_resource.artifact}" do
      to "/etc/init.d/#{new_resource.service_name}"
      link_type :symbolic
      mode new_resource.mode
    end

    template "#{new_resource.artifact_directory}/#{new_resource.service_name}.conf" do
      source 'artifact.conf.erb'
      mode new_resource.mode
      variables({
                  jar_file: new_resource.jar_file,
                  log_folder: new_resource.log_folder,
                  run_args: new_resource.run_args,
                  java_opts: new_resource.java_opts,
                  log_filename: new_resource.log_filename
                })
    end
  when 'systemd'
    systemd_unit 'jenkins.service' do
      content({
                Unit: {
                  Description: '#{service_name}',
                  After: 'network.target',
                  Requires: 'network.target'
                },
                Service: {
                  Type: 'simple',
                  User: new_resource.user,
                  Group: new_resource.group,
                  ExecStart: exec_start.string,
                  Restart: 'always',
                  RestartSec: '10s'
                },
                Install: {
                  WantedBy: 'multi-user.target'
                }
              })
      action [:create, :enable]
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end
  else
    raise "Unrecognized service type: #{type}"
  end

  service new_resource.service_name do
    action :start
  end
end
