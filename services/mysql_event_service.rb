class MysqlEventService
  def self.create_event(table, period, compare_column = 'created_at')
    return if period.to_i < 1

    event_sql = <<-sql
CREATE EVENT IF NOT EXISTS #{event_name(table)}
  ON SCHEDULE
    EVERY 1 DAY
    STARTS '#{1.day.since.beginning_of_day.to_s(:db)}'
  COMMENT 'Cleanup #{table} each day'
  DO
    BEGIN
      SET FOREIGN_KEY_CHECKS=0;
      DELETE FROM #{table} WHERE #{compare_column} < NOW() - INTERVAL #{period.to_i} DAY;
      SET FOREIGN_KEY_CHECKS=1;
    END
    sql

    execute(event_sql)
  end

  def self.update_event(table, period, compare_column = 'created_at')
    drop_event(table)
    create_event(table, period, compare_column)
  end

  def self.drop_event(table)
    execute("DROP EVENT IF EXISTS #{event_name(table)}")
  end

  protected

  def self.execute(sql)
    connection.execute(sql)
  end

  def self.event_name(table)
    "`#{connection.current_database}`.cleanup_#{table}"
  end

  def self.connection
    ActiveRecord::Base.connection
  end
end

