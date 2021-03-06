$server_list = {
  news1 => { 'server_url'    => 'news.provider.com',
  'port'          => '119',
  'enabled'       => '1', # 1 = enabled, 0 = disabled
  'username'      => 'testing',
  'password'      => 'test',
  'connections'   => '10',
  'ssl'           => '0', # 1 = enabled, 0 = disabled
  'retention'     => '0', # Time in days
  'backup_server' => '0', # 1 = enabled, 0 = disabled
  },
  news2 => { 'server_url'    => 'news.provider2.com',
  'port'          => '119',
  'enabled'       => '1', # 1 = enabled, 0 = disabled
  'username'      => 'dairyman88',
  'password'      => 'password123',
  'connections'   => '5',
  'ssl'           => '0', # 1 = enabled, 0 = disabled
  'retention'     => '120', # Time in days
  'backup_server' => '1', # 1 = enabled, 0 = disabled
  }
}

$categories = {
  tv => { 'directory' => 'TV' },
  movies => { 'directory' => 'Movies',
              'priority'   => '1',
  }
}

class { 'sabnzbd':
  servers     => $server_list,
  categories  => $categories,
}
