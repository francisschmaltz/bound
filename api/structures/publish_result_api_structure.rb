structure :publish_result do
  basic :zone_files_exported, "An array of all zone files that have been exported", :type => Array
  basic :zone_files_deleted, "An array of all zone files that have been deleted", :type => Array
  basic :zone_file_errors, "A hash containing any errors in zone files", :type => Hash
  basic :configuration_check, "Whether or not configuration has been checked", :type => :boolean
  basic :configuration_errors, "A string containing any errors from the configuration check", :type => String
  basic :reload, "Whether or not the master server has reloaded or not", :type => :boolean
  basic :slaves, "A hash containing details of zone files published to slaves", :type => Hash
end
