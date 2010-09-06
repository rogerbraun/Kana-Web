class Kana
  include DataMapper::Resource
  
  property :id, Serial
  property :utf8, String
  property :url, String

  has n, :flipcards
end

class Flipcard
  include DataMapper::Resource

  property :id, Serial
  property :last_learned_on, Date
  property :repetition, Integer, :default => 0
  property :easiness, Float, :default => 2.5
    
  def interval(n, ef)
    return 1 if n == 1
    return 6 if n == 2
    return (interval(n-1) * ef).round
  end

  def ef(oldef,q)
    puts "oldef: #{oldef}"
    puts "q: #{q}"
    ef = oldef+(0.1-(5-q)*(0.08+(4-q)*0.02))
    [ef,1.3].max
  end

  def learn_today?
    return true unless last_learned_on
    interval(repetition,easiness) < (Date.today - last_learned_on)
  end

  def learn(q)
    self.easiness = ef(self.easiness,q)
    self.last_learned_on = Date.today
    q < 3 ? self.repetition = 0 : self.repetition +=1
    save
  end

  def self.next(user)
    flipcards = user.flipcards.all.select{|f| f.learn_today?}
    flipcards.first
  end

  belongs_to :kana
  belongs_to :user
end

class User
  include DataMapper::Resource
  
  property :id, Serial
  property :openid, String
  property :email, String
  property :pwhash, String
  property :facebook_uid, String
  
  has n, :flipcards

  def reset
    flipcards.each(&:destroy)
    Kana.all.each do |kana|
      flipcard = Flipcard.new
      flipcard.kana = kana
      flipcards << flipcard
      save
    end 
  end

  def self.new_from_params(params)
    new_user = self.new
    new_user.email = params[:email].downcase
    new_user.pwhash = Digest::SHA1.hexdigest(params[:password])
    new_user.reset
    new_user.save
    new_user
  end

  def picture
    if facebook_uid then
      "http://graph.facebook.com/#{facebook_uid}/picture?type=square"
    else
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}?d=identicon" 
    end
  end

  def name

    if facebook_uid then
      # do facebook stuff
      #fb:name{:uid => fb[:user], :useyou => 'false', :firstnameonly => 'true'}
    else
      email.split("@")[0]
    end
  end

  def self.get_by_params(params)
    self.first(:email => params[:email].downcase, :pwhash => Digest::SHA1.hexdigest(params[:password]))
  end

  def self.get_by_fb(fb_uid)
    fb_user = first(:facebook_uid => fb_uid)
    if fb_user then
      fb_user
    else
      new_User = User.new
      new_User.facebook_uid = fb_uid
      new_User.save
      new_User.reset
      new_User
    end
  end
  
end
