require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
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

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    keys = params.keys.map(&:to_sym)
    keys.each do |k|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", params[k])
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
