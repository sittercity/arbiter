require_relative './app/bootstrap.rb'
require_relative './lib/bootstrap.rb'

Eventer.bus = Arbiter
Arbiter.set_listeners([Postmaster])
Postmaster.router = Router.new
Postmaster.record = Record.new
