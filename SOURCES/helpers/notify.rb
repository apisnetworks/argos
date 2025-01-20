#!/usr/bin/env ruby

require 'net/https'
require 'socket'
require 'shellwords'
require 'yaml'

@HIGH_PRIORITY = [
        'Does not exist.*mysql',
        'Too many'
]
ARGOS_CONF=File.dirname(__FILE__) + '/.argos.conf'
File.exist?(ARGOS_CONF) or exit
config = YAML.load_file(ARGOS_CONF)

if config["high_priority_tokens"]
        @HIGH_PRIORITY = [*config["high_priority_tokens"]]
end

re = Regexp.new('\bService\s*(?<svc>[^$]+)^$^\s*Date:\s*(?<date>.*?)$[\r\n]{1,2}
^\s*Action:\s*(?<action>.*?)$[\r\n]{1,2}
^\s*Host:\s*(?<host>(?<node>[^.]+).*?)$[\r\n]{1,2}
^\s*Description:\s*(?<desc>.*?)$', Regexp::MULTILINE|Regexp::EXTENDED)

# Take mail straight from STDIN
msg = ARGF.read
m = re.match(msg) || exit
if msg.match(Regexp.new(@HIGH_PRIORITY.join("|")))
        backend = 'high'
end
host = m['node']
if host == "server"
    host = ENV['ARGOS_NAME'] || Socket.gethostname
end
msg = "[#{host}] #{m[:svc]} #{m[:action]} - #{m[:desc]}"

`ntfy -c #{ARGOS_CONF} #{!backend.nil? ? '-b' + backend.shellescape : ''} send #{msg.shellescape}`