module CopyMove
  class CircularHierarchy < ActiveRecord::ActiveRecordError
    def initialize(record)
      @record = record
      super("Page #{record.title} cannot be made a descendant of itself.")
    end
  end
end