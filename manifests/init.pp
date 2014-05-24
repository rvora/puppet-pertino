#
# Author:: Rajul Vora <rvora@cloudopia.co>
# Module Name:: pertino
# Class:: pertino
#
# Copyright 2014, Pertino
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# == Class: pertino
#
# Install and configure Pertino Client
#
# === Parameters
#
# [*username*]
#   Pertino.com username
#
# [*password*]
#   Pertino.com password
#
# === Examples
#
#  class { pertino:
#    username => 'joe@example.com',
#    password => 'SuperSecretPassword',
#  }
#
class pertino (
    $username,
    $password
) {

    require pertino::dependencies
    Exec {
      path => '/usr/bin:/usr/sbin:/bin:/sbin',
    }
    
    # install package
    package { 'pertino-client':
      ensure => latest,
    }

    # authorize
    exec { 'auth-pertino':
      command => "/opt/pertino/pgateway/.pauth -u $username -p $password",
      cwd     => "/opt/pertino/pgateway",
      require => Package['pertino-client']
    }

    service { 'pgateway':
      ensure => running,
      enable => true,
      require => Exec['auth-pertino']
    }
}
