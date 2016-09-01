structure :record_type do
  basic :class, "The name of the type class", :type => String, :eg => "Bound::BuiltinRecordTypes::A", :value => proc { o.class.name }
  basic :name, "The name of the type", :type => String, :eg => "A", :value => proc { o.type }
  basic :color, "The color of the type", :type => String, :eg => "2b82df", :value => proc { o.class.color }
end
