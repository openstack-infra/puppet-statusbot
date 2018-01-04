# == Class: statusbot
#
class statusbot(
  $auth_nicks,
  $nick,
  $password,
  $server,
  $wiki_pageid,
  $wiki_password,
  $wiki_url,
  $wiki_user,
  $twitter_key = undef,
  $twitter_secret = undef,
  $twitter_token_key = undef,
  $twitter_token_secret = undef,
  $channels            = [],
  $irclogs_url         = undef,
  $wiki_successpageid  = undef,
  $wiki_successpageurl = undef,
  $wiki_thankspageid   = undef,
  $wiki_thankspageurl  = undef,
  $twitter             = undef,
) {

  user { 'statusbot':
    ensure     => present,
    home       => '/home/statusbot',
    shell      => '/bin/bash',
    gid        => 'statusbot',
    managehome => true,
    require    => Group['statusbot'],
  }

  group { 'statusbot':
    ensure => present,
  }

  vcsrepo { '/opt/statusbot':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/statusbot',
  }

  exec { 'install_statusbot' :
    command     => 'pip install /opt/statusbot',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/statusbot'],
  }

  file { '/etc/init.d/statusbot':
    ensure  => present,
    group   => 'root',
    mode    => '0555',
    owner   => 'root',
    require => Vcsrepo['/opt/statusbot'],
    source  => 'puppet:///modules/statusbot/statusbot.init',
  }

  service { 'statusbot':
    enable     => true,
    hasrestart => true,
    require    => File['/etc/init.d/statusbot'],
    subscribe  => [
      Vcsrepo['/opt/statusbot'],
      File['/etc/statusbot/statusbot.config'],
    ],
  }

  file { '/etc/statusbot':
    ensure => directory,
  }

  file { '/var/log/statusbot':
    ensure  => directory,
    owner   => 'statusbot',
    group   => 'statusbot',
    mode    => '0775',
    require => User['statusbot'],
  }

  file { '/var/run/statusbot':
    ensure  => directory,
    owner   => 'statusbot',
    group   => 'statusbot',
    mode    => '0775',
    require => User['statusbot'],
  }

  file { '/var/lib/statusbot':
    ensure  => directory,
    owner   => 'statusbot',
    group   => 'statusbot',
    mode    => '0775',
    require => User['statusbot'],
  }

  file { '/var/lib/statusbot/www':
    ensure  => directory,
    owner   => 'statusbot',
    group   => 'statusbot',
    mode    => '0775',
    require => [File['/var/lib/statusbot'],
                User['statusbot']]
  }

  file { '/etc/statusbot/logging.config':
    ensure  => present,
    group   => 'statusbot',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => User['statusbot'],
    source  => 'puppet:///modules/statusbot/logging.config',
  }

  file { '/etc/statusbot/statusbot.config':
    ensure  => present,
    content => template('statusbot/statusbot.config.erb'),
    group   => 'statusbot',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => User['statusbot'],
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
