every 1.day, at: '12:00 pm' do
  rake 'licenses:update_status'
end

# every 1.day, at: '12:00 pm' do
every 1.minute do
  command '/usr/bin/mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$MYSQL_ROOT_PASSWORD" mne_prod > /backup/mne_prod-$(date +%Y%m%d%H%M%S).sql'
end
