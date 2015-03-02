require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Person
  include DataMapper::Resource
  
  property :id,         Serial  
  property :email,      String, required: true
  property :first,      String
  property :school,     String, required: true
  property :created_at, DateTime, required: true
  
  has n, :visits, "Visit"
  
  def self.find_by_name(email)
    self.first(:email => email)
  end
end

class Visit
  include DataMapper::Resource
  
  property :id,         Serial 
  property :created_at, DateTime, required: true
  property :comments,   Text
  property :shown,      Integer,  default: 1
  
  belongs_to :person, "Person"
  
  def hide()
    self.shown = 0
  end
end
  
DataMapper.finalize()
DataMapper.auto_upgrade!()

get("/") do
  p "Hello World"
  records = Person.all(order: :created_at.desc)
  erb(:index, locals: { people: records })
end

get("/visits") do
  records = Person.all(order: :created_at.desc)
  erb(:visits, locals: { people: records })
end

post("/visit") do
  person = Person.find_by_name(params["email"]);
  if person == nil then
    person = Person.create(:created_at => DateTime.now, email: params["email"], first: params["first"], school: params["school"])
  end
  visit = Visit.create(:created_at => DateTime.now, :comments => params["comments"], :person => person)  
  if person.saved? and visit.saved? then
    redirect("/")
  else
    p person.errors
    p visit.errors
    erb(:error)
  end
end

post("/deletevisit/*") do |id|
  visit = Visit.get(id)
  visit.hide()
  visit.save
  redirect("/")
end

=begin
post("/messages") do
  message_body = params["body"]
  message_time = DateTime.now

  message = Message.create(body: message_body, created_at: message_time)

  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end
=end

