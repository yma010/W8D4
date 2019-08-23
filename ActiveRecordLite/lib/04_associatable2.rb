require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method(name) do
      through_opts = self.class.assoc_options[through_name]
      source_opts = through_opts.model_class.assoc_options[source_name]

      t_table = through_opts.table_name 
      t_p_key = through_opts.primary_key
      t_f_key = through_opts.foreign_key

      s_table = source_opts.table_name
      s_p_key = source_opts.primary_key
      s_f_key = source_opts.foreign_key

      val = self.send(t_f_key)
      data = DBConnection.execute(<<-SQL, val)
        SELECT
          #{s_table}.*
        FROM
          #{t_table}
        JOIN
          #{s_table} ON #{t_table}.#{t_p_key} = #{s_table}.#{s_p_key}
        WHERE
          #{t_table}.#{t_p_key} = ?
      SQL

      source_opts.model_class.parse_all(data).first
    end
  end
end
