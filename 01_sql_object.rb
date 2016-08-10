require_relative 'db_connection'
require_relative '02_searchable'
require_relative '03_associatable'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  extend Searchable
  extend Associatable
  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      LIMIT
        1
    SQL
    @cols.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}=") {|val| attributes[col] = val}
      define_method("#{col}") {attributes[col]}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    words = self.name.split /(?=[A-Z])/
    words.join('_').downcase + "s"
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    result = []
    results.each{|r| result << send("new", r)}
    result
    # ...
  end
  require 'byebug'
  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    return nil if result.empty?
    object = send("new", result.first)
  end

  def initialize(params = {})
    keys = params.keys#.map(&:to_sym)
    keys.each do |k|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", params[k])
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    #byebug
    self.class.columns.map{|el| send("#{el}")}
  end

  def insert
    col_names = self.class.columns.join(',')
    question_marks = (['?'] * self.class.columns.length)
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks.join(',')})
    SQL
    attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map{|n| "#{n.to_s} = ?"}.join(',')
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = #{attributes[:id]}
    SQL
  end

  def save
    if attributes[:id].nil?
      insert
    else
      update
    end
  end
end
