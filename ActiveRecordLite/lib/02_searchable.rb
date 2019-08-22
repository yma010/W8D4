require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    col_name = params.keys.map(&:to_s).join(" = ? AND ")
    col_name += " = ?"

    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{col_name}
    SQL

    parse_all(data)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
