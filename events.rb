require_relative './app/bootstrap.rb'
require_relative './lib/bootstrap.rb'

Eventer.bus = Arbiter.new([Postmaster])
Postmaster.router = Router.new
Postmaster.record = Record.new
Hello.new.say
