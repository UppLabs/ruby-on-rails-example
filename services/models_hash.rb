class ModelsHash
  HASH_FUNCTION = -> (value) { Digest::SHA1.hexdigest(value) }

  def initialize(class_name)
    @class = class_name.constantize rescue nil
  end

  def hash_value
    return 'wrong_model_name' unless @class

    scope = @class
    scope = scope.unscoped if @class.columns.detect { |c| c.name == 'deleted_at' }.present?
    columns = @class.columns.map(&:name).reject { |column| column =~ /_at$/ }

    if @class == User
      columns = columns.reject { |c| c =~ /_sign_in_ip^/ || c =~ /_job_id/ || c == 'sign_in_count' }
    end

    columns << 'updated_at' if @class == Activity::Item

    result = scope.select("MD5(CONCAT_WS(#{columns.map{ |c| "`#{c}`" }.join(', ')})) as digest")
    HASH_FUNCTION.call(result.map(&:digest).join)
  end
end

