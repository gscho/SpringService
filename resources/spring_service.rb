actions :default
default_action :default

property :artifact_directory, :name_attribute => false, :kind_of => String, :required => true
property :artifact, :name_attribute => false, :kind_of => String, :required => true
property :java_opts, :name_attribute => false, :kind_of => String, :required => false

resource_name 'spring_service'

action :default do

  artifact_name = File.basename(artifact, File.extname(artifact))
  
  link "#{artifact_directory}/#{artifact}" do
    to "/etc/init.d/#{artifact_name}"
    link_type :symbolic
    mode 755
  end

  template "#{artifact_directory}/#{artifact_name}.conf" do
    source 'artifact.conf.erb'
    mode 755
    variables({
      :v => java_opts
    })
    not_if java_opts.nil?
  end

end