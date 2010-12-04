module Prawnto
  module TemplateHandlers
    class Base < ::ActionView::TemplateHandler
      include ::ActionView::TemplateHandlers::Compilable
      
      def compile(template)
        "puts 'base';" + 
        "logger.warn 'BASE';" + 
        "_prawnto_compile_setup;" +
        "pdf = Prawn::Document.new(@prawnto_options[:prawn]);" + 
        template.source +
        "pdf.render;"
      end
    end
  end
end


