# encoding: utf-8
=begin
Filters for translations content.

Copyright (C) 2009 Andrey “A.I.” Sitnik <andrey@sitnik.ru>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

module R18n
  # Filter is a way, to process translations: escape HTML entries, convert from
  # Markdown syntax, etc.
  # 
  # In translation file filtered content must be marked by YAML type:
  # 
  #   filtered: !!no_space
  #     This content will be processed by filter
  # 
  # Filter function will be receive filtered content as first argument, current
  # locale as second and filter parameters as next arguments:
  # 
  #   R18n::Filters.add(:no_space) do |content, locale, replace|
  #     content.gsub(' ', replace)
  #   end
  #   
  #   i18n.filtered('_') #=> "This_content_will_be_processed_by_filter"
  # 
  # You can disable and enabled filters:
  # 
  #   R18n::Filters.off(:no_space)
  #   i18n.filtered('_') #=> "This content will be processed by filter"
  #   R18n::Filters.on(:no_space)
  #   i18n.filtered('_') #=> "This_content_will_be_processed_by_filter"
  module Filters
    class << self
      # Hash of filter names to Proc.
      def defined
        @defined ||= {}
      end
      
      # Enabled filters. Hash of names to Proc.
      def enabled
        @enabled ||= {}
      end
      
      # Add new filter with +name+. Filter content will be sent to +block+ as
      # first argument, locale as second and filters parameters will be in next
      # arguments.
      # 
      # If filter with this +name+ already exists, it will be replaced.
      def add(name, &block)
        name = name.to_s
        defined[name] = block
        enabled[name] = block
      end
      
      # Delete filter with +name+.
      def delete(name)
        name = name.to_s
        defined.delete(name)
        enabled.delete(name)
      end
      
      # Disable filter with +name+.
      def off(name)
        enabled.delete(name.to_s)
      end
      
      # Turn on disabled filter with +name+.
      def on(name)
        name = name.to_s
        return false unless defined.has_key? name
        enabled[name] = defined[name]
      end
      
      # Return enabled filter with +name+.
      def [](name)
        enabled[name.to_s]
      end
    end
  end
  
  Filters.add(:proc) do |content, locale, *params|
    if R18n.call_proc
      eval("proc { #{content} }").call(*params)
    else
      content
    end
  end
  
  Filters.add(:pl) do |content, locale, param|
    type = locale.pluralize(param)
    type = 'n' if not content.include? type
    content[type]
  end
end