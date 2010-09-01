class Kana
  include DataMapper::Resource
  
  property :id, Serial
  property :utf8, String
  property :url, String

  belongs_to :flipcard, :required => false
end

class Flipcard
  include DataMapper::Resource

  property :id, Serial
  property :last_learned_on, Date
  property :repetition, Integer, :default => 0
  property :easiness, Decimal, :default => 2.5
    
  def interval(n, ef)
    return 1 if n == 1
    return 6 if n == 2
    return (interval(n-1) * ef).round
  end

  def ef(oldef,q)
    ef = ef+(0.1-(5-q)*(0.08+(4-q)*0.02))
    [ef,1.3].max
  end

  def learn_today?
    interval(repetition) < (Date.now - last_learned_on)
  end

  def learn(q)
    easiness = ef(easiness,q)
    last_learned_on = Date.today
    q < 3 ? repetition = 0 : repetition +=1
    save
  end

  has 1, :kana
  belongs_to :user
end

class User
  include DataMapper::Resource
  
  property :id, Serial
  property :openid, String
  property :email, String
  property :pwhash, String
  
  has n, :flipcards

  def reset
    flipcards.each(&:destroy)
    Kana.all.each do |kana|
      flipcard = Flipcard.new
      flipcard.kana = kana
      flipcards << flipcard
    end 
    save
  end

end
