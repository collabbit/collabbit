module Authority
      
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  def viewable_by?(usr);    false; end;
  def destroyable_by?(usr); false; end;
  def updatable_by?(usr);   false; end;
  
  def requires_override?
    self.class.requires_override?
  end
  
  module ClassMethods
    
    @override_required = false    
    
    def owned_by(field)
      define_method(:viewable_by?) {|usr| send(field) == usr }
      define_method(:updatable_by?) {|usr| send(field) == usr }
      define_method(:destroyable_by?) {|usr| send(field) == usr }
    end

    def inherits_permissions_from(field)
      define_method(:viewable_by?) {|usr| send(field).viewable_by?(usr) }
      define_method(:updatable_by?) {|usr| send(field).updatable_by?(usr) }
      define_method(:destroyable_by?) {|usr| send(field).destroyable_by?(usr) }
    end
    
    def requires_override?
      @override_required || false
    end
    
    def requires_override!
      @override_required = true
    end
  end
end