require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map{|el| "#{el} = ?"}.join(' AND ')
    search_result = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    result = []
    search_result.each{|el| result << self.new(el)}
    result
  end
end
