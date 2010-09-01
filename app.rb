require "rubygems"
require "sinatra"
require "haml"

class Supermemo2
# see http://www.supermemo.com/english/ol/sm2.htm


  def interval(n, ef)
    return 1 if n == 1
    return 6 if n == 2
    return (interval(n-1) * ef).round
  end

  def ef(oldef,q)
    ef = ef+(0.1-(5-q)*(0.08+(4-q)*0.02))
    [ef,1.3].max
  end

end


get "/" do
  haml :index
end
