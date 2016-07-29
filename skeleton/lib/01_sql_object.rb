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
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
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
