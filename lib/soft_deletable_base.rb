
class SoftDeletableBase < ActiveRecord::Base
  attr_accessor :reasons_not_to_delete

  self.abstract_class = true

  scope :extant, where(["#{(self.class.name.tableize + ".") if self.class.kind_of?(SoftDeletableBase)}deleted_at IS NULL"])
  scope :deleted, where(["#{(self.class.name.tableize + ".") if self.class.kind_of?(SoftDeletableBase)}deleted_at IS NOT NULL"])

  # Overwrite this method to add actions that are triggered before soft_delete operates.
  def before_soft_delete

  end

  # Rename this 'delete' if you wish this functionality to replace the
  # default delete behaviour.
  def soft_delete
    before_soft_delete
    unless reasons_not_to_delete?
      update_attribute(:deleted_at, Time.now)
      after_soft_delete
      return 'deleted'
    else
      errors.add(:base, "Unable to delete. reasons_not_to_delete returns #{@reasons_not_to_delete || 'true'} for #{inspect}")
    end
  end

  # Overwrite this method to add actions that are triggered after soft_delete operates.
  def after_soft_delete

  end

  # Overwrite this method to add actions that are triggered before recover_soft_deleted operates.
  def before_recover_soft_deleted

  end

  def recover_soft_deleted
    before_recover_soft_deleted
    update_attribute(:deleted_at, nil)
    after_recover_soft_deleted
  end

  # Overwrite this method to add actions that are triggered after recover_soft_deleted operates.
  def after_recover_soft_deleted

  end

  def is_deleted?
    deleted_at != nil
  end

  def deleted?
    is_deleted?
  end

  def is_extant?
    !deleted_at
  end

  def extant?
    is_extant?
  end

  # You can either overwrite this method to add methods that prevent soft
  # deletion, or set @reasons_not_to_delete to true. For example, set
  # @reasons_not_to_delete = 'Component needs to be deleted first'
  def reasons_not_to_delete?
    @reasons_not_to_delete
  end

  private
  def table_name_modifier
    klass = self.class
    if klass.kind_of?(SoftDeletableBase) and !klass.instance_of(SoftDeletableBase)
      "#{klass.name.tableize}."
    else
      ""
    end
  end
  
end


