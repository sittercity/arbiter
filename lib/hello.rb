require_relative './eventer'

class Hello
  def say
    Eventer.post(:hello, 5)
  end
end
