namespace :licenses do
  desc "Update expired licenses's status"
  task update_status: :environment do
    License.expires.find_each do |license|
      license.update_attributes(status: :archived)
    end
  end
end
