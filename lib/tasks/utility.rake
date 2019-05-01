namespace :leaf_addons do
  desc "Delete any unused Hydra::AccessControl objects"
  task cleanup_accesscontrol: :environment do
    Hydra::AccessControl.all.each do |access_control|
      if access_control.contains == []
        puts "Deleting #{access_control.id}"
        access_control.destroy.eradicate
      end
    end
  end
end
