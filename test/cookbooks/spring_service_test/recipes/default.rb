#
# Cookbook:: spring_service_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

spring_service 'test' do
	artifact_directory '/testdir'
	artifact 'test.jar'
	java_opts '-xmx512m'
end