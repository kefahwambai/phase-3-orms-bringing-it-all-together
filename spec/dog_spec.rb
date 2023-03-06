class Dog
  attr_accessor :name, :breed, :id;

  def initialize(name:, breed:, id: nil)
      @name = name
      @breed = breed
      @id = id
  end

  def self.create_table
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = <<-SQL
          DROP TABLE dogs
      SQL
      DB[:conn].execute(sql)
  end

  def save
      sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].last_insert_row_id()
      self
  end

  def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
  end

  def self.new_from_db(record)
      dog = Dog.new(id: record[0], name: record[1], breed: record[2])
      dog.save
  end

  def self.all
      sql = <<-SQL
          SELECT * FROM dogs
      SQL

      DB[:conn].execute(sql).map { |row| Dog.new(id: row[0], name: row[1], breed: row[2]) }
  end

  def self.find_by_name(dogs_name)
      sql = <<-SQL
          SELECT * FROM dogs
          WHERE name =?
          LIMIT 1
      SQL

      DB[:conn].execute(sql, dogs_name).map { |row| Dog.new(id: row[0], name: row[1], breed: row[2]) }[0]
  end

  def self.find(id)
      sql = <<-SQL
          SELECT * FROM dogs
          WHERE id =?
      SQL

      DB[:conn].execute(sql, id).map { |row| Dog.new(id: row[0], name: row[1], breed: row[2]) }[0]
  end

  def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          LIMIT 1
      SQL

      dogs = DB[:conn].execute(sql, name, breed)
      if(dogs.size > 0)
          return Dog.new(id: dogs[0][0], name: dogs[0][1], breed: dogs[0][2])
      else
          newDog = Dog.new(name: name, breed: breed)
          return newDog.save
      end
  end

  def update
      sql = <<-SQL
          UPDATE dogs
          SET name =?, breed =?
          WHERE id =?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

  # BONUS! uncomment the tests below for an extra challenge
  # describe '.find_or_create_by' do
  #   it 'creates an instance of a dog if it does not already exist' do
  #     dog1 = Dog.create(name: 'teddy', breed: 'cockapoo')
  #     dog2 = Dog.find_or_create_by(name: 'teddy', breed: 'cockapoo')

  #     expect(dog2.id).to eq(dog1.id)
  #   end

  #   it 'when two dogs have the same name and different breed, it returns the correct dog' do
  #     dog1 = Dog.create(name: 'teddy', breed: 'cockapoo')
  #     Dog.create(name: 'teddy', breed: 'pug')

  #     dog_from_db = Dog.find_or_create_by(name: 'teddy', breed: 'cockapoo')

  #     expect(dog_from_db.id).to eq(1)
  #     expect(dog_from_db.id).to eq(dog1.id)
  #   end

  #   it 'when creating a new dog with the same name as persisted dogs, it returns the correct dog' do
  #     Dog.create(name: 'teddy', breed: 'cockapoo')
  #     Dog.create(name: 'teddy', breed: 'pug')

  #     new_dog = Dog.find_or_create_by(name: 'teddy', breed: 'irish setter')

  #     expect(new_dog.id).to eq(3)
  #   end
  # end

  # describe '#update' do
  #   it 'updates the record associated with a given instance' do
  #     teddy = Dog.create(name: "Teddy", breed: "cockapoo")
  #     teddy.name = "Teddy Jr."
  #     teddy.update
  #     also_teddy = Dog.find_by_name("Teddy Jr.")
  #     expect(also_teddy.id).to eq(teddy.id)
  #   end
  # end

  # context 'when called on a record with an ID' do
  #   describe '#save' do
  #     it 'updates the record associated with a given instance' do
  #       teddy = Dog.create(name: 'teddy', breed: 'cockapoo')
  #       teddy.name = "Teddy Jr."
  #       teddy.save
  #       also_teddy = Dog.find_by_name("Teddy Jr.")
  #       expect(also_teddy.id).to eq(teddy.id)
  #     end
  #   end
  # end

end
