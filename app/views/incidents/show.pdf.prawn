pdf.font_size 16
pdf.text "Report for #{@incident.name}", :align => :center, :style => :bold
pdf.font_size 12
pdf.text "Incident created on #{time_mdy(@incident.created_at).gsub!(/(&nbsp;|\s)+/, " ")}", :align => :right
pdf.text "Report generated on #{time_mdy(DateTime.now).gsub!(/(&nbsp;|\s)+/, " ")}", :align => :right
pdf.text "Incident #{@incident.closed? ? 'closed' : 'open'}"
pdf.text "Description", :style => :bold
pdf.text "#{@incident.description}"
pdf.text "No of Updates :", :style => :bold
pdf.move_up(14)
pdf.indent(90) do pdf.text "#{@filtered_updates.size}" end
i = 0
@filtered_updates.reverse!
@filtered_updates.each do |u|
   i = i+1
   pdf.text " "
   pdf.font_size 14
   pdf.text "#{i}. #{u.title}", :align => :center, :style => :bold
   pdf.font_size 12
   pdf.text ""
   pdf.text "#{u.issuing_name}", :align => :left, :style => :bold
   pdf.move_up(12)
   pdf.indent(300) do pdf.text "On #{time_mdy(u.created_at).strip.gsub!(/(&nbsp;|\s)+/, " ")}", :align => :right end
   pdf.text ""
   pdf.text "#{u.text}", :size => 13
   pdf.indent(20) do pdf.text "Groups", :style => :bold end
   pdf.move_up(12)
   pdf.indent(100) do pdf.text "#{u.relevant_groups.find(:all, :order => 'name').map(&:name).join(', ') || '(none specified)'}", :align => :left end
   pdf.indent(20) do pdf.text "Tags", :style => :bold end
   pdf.move_up(12)
   pdf.indent(100) do pdf.text "#{u.tags.find(:all, :order => 'name').map(&:name).join(', ') || '(none specified)'}", :align => :left end
   pdf.indent(20) do pdf.text "Attachments", :style => :bold end
   pdf.move_up(12)
   pdf.indent(100) do pdf.text "#{u.attached_files.size}" end
   pdf.indent(20) do pdf.text "Comments: ", :align => :left, :style => :bold end
   u.comments.each do |c|
     pdf.text " "
     pdf.indent(50) do
        pdf.text "#{c.user.full_name}", :style => :bold
        pdf.move_up(12)
        pdf.indent(300) do pdf.text "#{time_mdy(c.created_at).gsub!(/(&nbsp;|\s)+/, " ")}", :align => :right, :size => 10  end
        pdf.indent(75) do
            pdf.text "#{c.body}", :size => 11, :left_margin => 100, :final_gap => :true
        end 
     end   
   end
end
