controller :records do

  friendly_name "Records API"
  description "This API allows you to add, edit & remove records for a zone"

  action :list do
    title "List all records"
    use :find_zone
    returns Array, :structure => :record, :structure_opts => {:expansions => [:type]}
    action do
      @zone.ordered_records.includes(:zone).map do |record|
        structure record, :return => true
      end
    end
  end

  action :create do
    title "Create a new record"
    description "This action will create a new record within a zone"
    use :find_zone
    from_structure :record do
      param :name
      param :ttl
      param :form_data, :default => {}
      param :type, :type => String, :default => "Bound::BuiltinRecordTypes::A"
    end
    returns Hash, :structure => :record, :structure_opts => {:full => true}
    use :validation_error
    action do
      record = @zone.records.build
      copy_params_to record, :name, :ttl, :form_data, :type
      record.save!
      structure record, :return => true
    end
  end

  shared_action :find_record do
    param :record_id, "The ID of the record", :type => Integer, :required => true
    error 'ZoneNotFound', "No record was found given the ID provided", :attributes => {:id => "The provided ID"}
    action do
      @record = Record.find_by_id(params.record_id) || error('RecordNotFound', :record_id => params.record_id)
    end
  end

  action :update do
    title "Update a record"
    description "This action will update an existing record"
    use :find_record
    from_structure :record do
      param :name
      param :ttl
      param :form_data
      param :type, :type => String
    end
    returns Hash, :structure => :record, :structure_opts => {:full => true}
    action do
      copy_params_to @record, :name, :ttl, :form_data, :type
      @record.save!
      structure @record, :return => true
    end
  end

  action :destroy do
    title "Destroy a record"
    description "This action will remove an existing record"
    use :find_record
    returns :boolean
    action do
      @record.destroy!
      true
    end
  end

end
