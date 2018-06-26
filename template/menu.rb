menu_config = [
                {prompt: 'Select Application', options: ['WEBAPP': '', 'API': '--api']},
                {prompt: 'Select Database', options: ['SQLITE': '', 'POSTGRES': '-d postgresql']},
                {prompt: 'Select Webpack', options: ['NONE': '', 'REACT': '--webpack=react', 'ANGULAR': '--webpack=angular', 'VEU': '--webpack=veu']}
             ]

final_options = []
menu_config.each do |menu|
   puts "#{menu[:prompt]} :" 
   menu[:options].each do |menu_options|
      menu_options.each_with_index do |(menu_key,menu_value), menu_index|
        puts "  <#{menu_index+1}>  #{menu_key}"
      end  
   end
   print "Enter your option : "
   selected_option = gets.chomp
   final_options << menu[:options].first.to_a[selected_option.to_i - 1].last
end
result = final_options.join(" ")
result
`touch .rails-new`
`echo #{result} > .rails-new`


