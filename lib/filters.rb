require 'active_record'

ActiveRecord::Base.class_eval do
  def self.find_with_filters(*args)
    join_conds = {}
    column_conds = {}
    fltrs = {}
    args.each {|a| fltrs = a[:filters] if a.is_a?(Hash) && a.include?(:filters)}
    fltrs.each_pair do |k,v|
      if column_names.include?(k.to_s)
        column_conds[k] = v
      else
        join_conds[k] = v
      end
    end
    
    return do_filters(find(*args+[:conditions => column_conds]), join_conds)
  end
  
  protected
    def self.do_filters(objs, flts)
      return objs.select do |obj|
        good = true
        flts.each_pair do |k,v|
          logger.info { "Applying #{obj.send(k)} and #{v}" }
          good = false unless apply_filter(obj.send(k), v)
        end
        good
      end
    end
    def self.apply_filter(obj, flt)
      if obj.is_a?(Array) && flt.is_a?(Hash) # like [#<Group>, ...], {:id => 4}
        return do_filters(obj, flt).size > 0
      elsif obj.is_a?(Array) && flt.is_a?(Array) # like [1,2,3], [2,4,6]
        return ((obj.map{|o|o.hash} | flt.map{|f|f.hash}) & (obj | flt)).size > 0
      elsif obj.is_a? Array # like [1,3,5], 3
        return (obj.map{|o|o.hash}).include?(flt.hash) || obj.include?(flt)
      elsif flt.is_a? Array # like 7, [0,4,6,7]
        return (flt.map{|f|f.hash}).include?(obj.hash) || flt.include?(obj)
      elsif flt.is_a? Hash # like #<User:...>, {:id => 5, :foo => :bar}
        return do_filters([obj], flt).size > 0
      else # like 7, 7
        return obj.hash == flt.hash
      end
    end
end