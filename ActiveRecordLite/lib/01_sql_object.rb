require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns
    columns = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name};
    SQL

    @columns = columns.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |val|
        self.attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.tableize
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(data)
  end

  def self.parse_all(results)
    # ...
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    # ...
    cat = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ? 
    SQL

    parse_all(cat).first
  end

  def initialize(params = {})
    # ...
    params.each do |col, val|
      sym_col = col.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(sym_col)
      self.send("#{col}=", val)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map {|column| self.send(column)dfs}
  end
  
  def insert
    num_questions = ["?"] * self.class.columns.length
    # ...
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.table_name} (#{*columns})
      VALUES
          (#{*num_questions})
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
