require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE students')
  end

  def save
    if self.id
      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
        SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute('SELECT last_insert_rowid()')[0][0]
    end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    db_student = self.new(row[1], row[2], row[0])
    db_student
  end

  def self.find_by_name(student)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      SQL

    db_student = DB[:conn].execute(sql, student)[0]
    self.new_from_db(db_student)
  end

  def update
    self.save
  end

end
