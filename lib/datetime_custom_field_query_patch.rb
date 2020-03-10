require_dependency 'query'
require_dependency 'issue_query'

# Module mixed with Query model

module DatetimeCustomFieldQueryPatch
  ###########################
  # Plugin : method REWRITTEN
  def validate_query_filters
    filters.each_key do |field|
      if values_for(field)
        case type_for(field)
        when :integer
          add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(,[+-]?\d+)*\z/) }
        when :float
          add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/\A[+-]?\d+(\.\d*)?\z/) }
        when :date, :date_past
          case operator_for(field)
          when "=", ">=", "<=", "><"
            add_filter_error(field, :invalid) if values_for(field).detect {|v|

              ###############
              ### Patch Start
              # Add new valid date formats
              v.present? && ((!v.match(/\A\d{4}-\d{2}-\d{2}(T\d{2}((:)?\d{2}){0,2}(Z|\d{2}:?\d{2})?)?\z/) && !v.match(/\A\d{2}\/\d{2}\/\d{4}(T\d{2}((:)?\d{2}){0,2}(Z|\d{2}:?\d{2})?)?\z/)) || parse_date(v).nil?)
              ### Patch End
              #############

            }
          when ">t-", "<t-", "t-", ">t+", "<t+", "t+", "><t+", "><t-"
            add_filter_error(field, :invalid) if values_for(field).detect {|v| v.present? && !v.match(/^\d+$/) }
          end
        end
      end

      add_filter_error(field, :blank) unless
          # filter requires one or more values
          (values_for(field) and !values_for(field).first.blank?) or
          # filter doesn't require any value
          ["o", "c", "!*", "*", "t", "ld", "w", "lw", "l2w", "m", "lm", "y", "*o", "!o"].include? operator_for(field)
    end if filters
  end

  # Plugin : method REWRITTEN
  def quoted_time(time, is_custom_filter)
    if is_custom_filter
      # Custom field values are stored as strings in the DB
      # using this format that does not depend on DB date representation
      if Rails.env.test?
        # UPSTREAM version
        time.strftime("%Y-%m-%d %H:%M:%S")
      else
        ########################
        # Plugin : Custom format
        time.strftime("%d/%m/%Y %H:%M")
      end
    else
      self.class.connection.quoted_date(time)
    end
  end

  ###########################
  # Plugin : method REWRITTEN
  #
  # Returns a SQL clause for a date or datetime field.
  def date_clause(table, field, from, to, is_custom_filter)
    s = []
    if from
      if from.is_a?(Date)
        from = date_for_user_time_zone(from.year, from.month, from.day).yesterday.end_of_day
      else
        from = from - 1 # second
      end
      if self.class.default_timezone == :utc
        from = from.utc
      end

      ###############
      ### Patch Start
      # Fix comparison for PostgreSQL
      if is_custom_filter && self.class.connection.kind_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && !Rails.env.test?
        s << ("to_timestamp(#{table}.#{field},'DD/MM/YYYY HH24:MI') > to_timestamp('%s','DD/MM/YYYY HH24:MI')" % [quoted_time(from, is_custom_filter)])
      else
        # Upstream version
        s << ("#{table}.#{field} > '%s'" % [quoted_time(from, is_custom_filter)])
      end
      ### Patch End
      #############
    end
    if to
      if to.is_a?(Date)
        to = date_for_user_time_zone(to.year, to.month, to.day).end_of_day
      end
      if self.class.default_timezone == :utc
        to = to.utc
      end

      ###############
      ### Patch Start
      # Fix comparison for PostgreSQL
      if is_custom_filter && self.class.connection.kind_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && !Rails.env.test?
        s << ("to_timestamp(#{table}.#{field},'DD/MM/YYYY HH24:MI') <= to_timestamp('%s','DD/MM/YYYY HH24:MI')" % [quoted_time(to, is_custom_filter)])
      else
        # Upstream version
        s << ("#{table}.#{field} <= '%s'" % [quoted_time(to, is_custom_filter)])
      end
      ### Patch End
      #############
    end
    s.join(' AND ')
  end
end

