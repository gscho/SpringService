name 'spring_service'
maintainer 'Greg Schofield'
maintainer_email 'gregs@indellient.com'
license 'all_rights'
description 'Installs/Configures spring_service'
long_description 'Installs/Configures spring_service'
version '0.2.0'

def url(name)
  "https://github.com/gscho/spring_service/#{name}"
end

issues_url url issues if respond_to?(:issues_url)
source_url url spring_service if respond_to?(:source_url)
