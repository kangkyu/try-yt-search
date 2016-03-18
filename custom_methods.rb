class Hash
  def to_query
    to_h.map do |key, value|
      key.query_itemize + "=" + value.to_s
    end.join("&")
  end
end

class Symbol
  def query_itemize
    words = to_s.split('_')
    words.shift.downcase + words.map(&:capitalize).join
  end
end
