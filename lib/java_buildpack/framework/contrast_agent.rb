# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2016 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'net/http'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Contrast support.
    class ContrastAgent < JavaBuildpack::Component::BaseComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        @droplet.copy_resources
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        configuration = {}
        apply_configuration(configuration)
        write_java_opts(java_opts, configuration)
      	contrast_agent_path = "WEB-INF/lib/contrast.jar"
        java_opts   = @droplet.java_opts
        java_opts.add_javaagent(contrast_agent_path)
        return java_opts
      end

      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
		agent_path = File.join ARGV[0], "WEB-INF/lib/contrast.jar"
		if File.exist?(agent_path)
		  puts Time.now.to_i
		  puts "#{self.class.to_s.dash_case}=3.2.7"
		  exit 0
		else
		  exit 1
		end
	  end

      def apply_configuration(configuration)
        configuration['log_file_name'] = 'STDOUT'
        configuration['app_name'] = @application.details['application_name']
      end


    end
  end
end
