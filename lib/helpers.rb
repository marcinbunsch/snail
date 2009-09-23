module Helpers
  
  def link_to(text, link='#', options = {})
    tag = "<a href='#{link}'"
    tag += " class=\"#{options[:class]}\"" if options[:class]
    tag += " target=\"#{options[:target]}\"" if options[:target]
    tag += " onclick=\"#{options[:onclick]}\"" if options[:onclick]
    tag += ">#{text}</a>"
  end
  
  def image_tag(file, options={})
    tag = "<img src='/images/#{file}'"
    tag += " alt='#{options[:alt]}' title='#{options[:alt]}' " if options[:alt]
    tag += "/>"
  end
  
  def partial(name, options={})
    erb("_#{name.to_s}".to_sym, options.merge(:layout => false))
  end
  
  def time_ago_or_time_stamp(from_time, to_time = Time.now, include_seconds = true, detail = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round
      case distance_in_minutes
        when 0..1           then time = (distance_in_seconds < 60) ? "#{distance_in_seconds} seconds ago" : '1 minute ago'
        when 2..59          then time = "#{distance_in_minutes} minutes ago"
        when 60..90         then time = "1 hour ago"
        when 90..1440       then time = "#{(distance_in_minutes.to_f / 60.0).round} hours ago"
        when 1440..2160     then time = '1 day ago' # 1-1.5 days
        when 2160..2880     then time = "#{(distance_in_minutes.to_f / 1440.0).round} days ago" # 1.5-2 days
        else time = from_time.strftime("%a, %d %b %Y")
      end
      return time_stamp(from_time) if (detail && distance_in_minutes > 2880)
      return time
    end
  
  def table(collection, *columns)   
    return '' if collection.size == 0
    raise 'Collection element is not a Hash' if collection.first.class != Hash
    if columns == []
      # auto load a list of keys
      first = collection.first
      columns = first.keys
    end
    html = '<table class="list">'
    html << "\n<tr><th>" + columns.join('</th><th>') + '</th>'
    html << '<th>options</th>' if block_given?
    html << '</tr>'
    iterator = 0
    collection.each do |item|
      html << "\n<tr#{ ' class="alt"' if iterator%2==0}>"
      item.each_pair { |key, value| html << "<td>#{value}</td>" if columns.include?(key.to_sym) }
      if block_given?
        html << "<td>#{yield(item)}</td>" 
      end
      html << '<tr>'
      iterator += 1
    end
    html << "\n</table>"
  end
  
  def to_query(hash = {})
    raise 'Not a hash' if hash.class != Hash
    hash.keys.collect { |key| "#{key}=#{hash[key]}" }.join('&amp;')
  end
end