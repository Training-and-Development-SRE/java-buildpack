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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/contrast_agent'
require 'java_buildpack/util/tokenized_version'

describe JavaBuildpack::Framework::ContrastAgent do
  include_context 'component_helper'

  it 'does not detect without contrast-n/a service' do
    expect(component.detect).to be_nil
  end

  context do

    before do
      allow(services).to receive(:one_service?).with(/contrast/, %w(licenseKey license_key)).and_return(true)
    end

    it 'detects with contrast-n/a service' do
      expect(component.detect).to eq("contrast-agent=#{version}")
    end

    it 'downloads New Relic agent JAR',
       cache_fixture: 'stub-contrast-agent.jar' do

      component.compile

      expect(sandbox + "contrast_agent-#{version}.jar").to exist
    end

    it 'copies resources',
       cache_fixture: 'stub-contrast-agent.jar' do

      component.compile

      expect(sandbox + 'contrast.yml').to exist
    end

    it 'updates JAVA_OPTS' do
      allow(services).to receive(:find_service).and_return('credentials' => { 'licenseKey' => 'test-license-key' })
      allow(java_home).to receive(:java_8_or_later?).and_return(JavaBuildpack::Util::TokenizedVersion.new('1.7.0_u10'))

      component.release

      expect(java_opts).to include("-javaagent:$PWD/.java-buildpack/contrast_agent/contrast_agent-#{version}.jar")
      expect(java_opts).to include('-Dcontrast.home=$PWD/.java-buildpack/contrast_agent')
      expect(java_opts).to include('-Dcontrast.config.license_key=test-license-key')
      expect(java_opts).to include('-Dcontrast.config.app_name=test-application-name')
      expect(java_opts).to include('-Dcontrast.config.log_file_name=STDOUT')
    end

    it 'updates JAVA_OPTS with additional options' do
      allow(services).to receive(:find_service).and_return('credentials' => { 'licenseKey' => 'test-license-key',
                                                                              'license_key' => 'different-license-key',
                                                                              'app_name' => 'different-name',
                                                                              'foo' => 'bar' })
      allow(java_home).to receive(:java_8_or_later?).and_return(JavaBuildpack::Util::TokenizedVersion.new('1.7.0_u10'))

      component.release

      expect(java_opts).to include('-Dcontrast.config.license_key=different-license-key')
      expect(java_opts).to include('-Dcontrast.config.app_name=different-name')
      expect(java_opts).to include('-Dcontrast.config.foo=bar')
    end

    it 'updates JAVA_OPTS on Java 8' do
      allow(services).to receive(:find_service).and_return('credentials' => { 'licenseKey' => 'test-license-key' })
      allow(java_home).to receive(:java_8_or_later?).and_return(JavaBuildpack::Util::TokenizedVersion.new('1.8.0_u10'))

      component.release

      expect(java_opts).to include('-Dcontrast.enable.java.8=true')
    end

  end

end
