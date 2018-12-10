class Dog
  attr_accessor :name,:breed
  attr_reader :id

  def initialize(name:nil,breed:nil,id:nil)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY,name TEXT,breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    sql=<<-SQL
     INSERT INTO dogs(name,breed)
     VALUES(?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:nil,breed:nil)
    new_dog=Dog.new(name:name,breed:breed)
    new_dog.save
  end

  def self.find_by_id(id)
    sql=<<-SQL
      SELECT * FROM dogs
      WHERE id=?
    SQL

    row=DB[:conn].execute(sql,id)
    Dog.new(id:row[0][0],name:row[0][1],breed:row[0][2])
  end

  def self.find_or_create_by(name:nil,breed:nil)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
     Dog.new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_name(name)
    sql="SELECT * FROM dogs WHERE name=?"
    DB[:conn].execute(sql,name).map do |row|
      Dog.new(id:row[0],name:row[1],breed:row[2])
    end.first
  end

  def update
    sql="UPDATE dogs SET name=?,breed=? WHERE id=?"

    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

end