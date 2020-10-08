class AddPushNotificationsToPacketTypes < ActiveRecord::Migration
  def self.up
    table = Arel::Table.new(:packet_types)
    %w(push_notifications/setup).each do |name|
      Arel::InsertManager.new(ActiveRecord::Base).tap do |insert|
        insert.insert([[table[:name], name], [table[:show_on_tracking], true]])
        execute(insert.to_sql)
      end
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end

