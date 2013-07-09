namespace :arbiter do
  desc 'Run ZeroMQ Worker'
  task :worker, :backend do |cmd, args|
    require 'zeromq_arbiter'

    ZeromqArbiter.logger = Logger
    ZeromqArbiter.new.listen(args[:backend])
  end

  desc 'Run ZeroMQ Proxy'
  task :proxy, :frontend_uri, :backend_uri do |cmd, args|
    require 'zeromq/proxy'

    Logger.info 'Starting proxy...'

    Zeromq::Proxy.new(args[:frontend_uri], args[:backend_uri]).execute
  end
end
