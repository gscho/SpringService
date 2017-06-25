if defined?(ChefSpec)
  def default_spring_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:spring_service, :default, resource_name)
  end
end