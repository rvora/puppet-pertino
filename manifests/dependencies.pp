#
# Author:: Rajul Vora <rvora@cloudopia.co>
# Module Name:: pertino
# Class:: pertino::dependencies
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

class pertino::dependencies {

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin',
  }

  case $::operatingsystem {
    'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora': {

      $rpmkey = '/etc/pki/rpm-gpg/RPM-GPG-KEY-Pertino'

      file { $rpmkey:
        ensure => present,
        source => 'puppet:///modules/pertino/RPM-GPG-KEY-Pertino',
      }

      exec { 'import_key':
        command     => "/bin/rpm --import $rpmkey",
        subscribe   => File[$rpmkey],
        refreshonly => true,
      }

      yumrepo { 'pertino':
        descr    => "Pertino $::operatingsystemrelease $::architecture Repository ",
        enabled  => 1,
        baseurl  => $::operatingsystem ? {
          /(RedHat|redhat|CentOS|centos)/ =>  "https://yum.cloudopia.co/centos/os/$::operatingsystemrelease/$::architecture/",
          'Fedora'                        =>  "https://yum.cloudopia.co/centos/os/6.4/$::architecture/",
          'Amazon'                        =>  "https://yum.cloudopia.co/centos/os/6.4/$::architecture/",
        },
        gpgcheck => 1,
        gpgkey   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-Pertino',
      }
    }

    'debian', 'ubuntu': {

      package { 'apt-transport-https':
        ensure => latest,
      }

      file { '/etc/apt/trusted.gpg.d/pertino.gpg':
        source => 'puppet:///modules/pertino/pertino.gpg',
        notify => Exec['add-pertino-apt-key'],
      }

      exec { 'add-pertino-apt-key':
        command     => 'apt-key add /etc/apt/trusted.gpg.d/pertino.gpg',
        refreshonly => true,
      }

      file { '/etc/apt/sources.list.d/pertino.list':
        ensure  => present,
        content => template('pertino/apt_source.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [Package['apt-transport-https'],
                    File['/etc/apt/trusted.gpg.d/pertino.gpg']],
        notify  => Exec['apt-update']
      }

      exec { 'apt-update':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
      }
    }

    default: {
      fail('Platform not supported by Pertino module. Patches welcomed.')
    }
  }
}
