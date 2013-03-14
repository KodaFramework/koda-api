def run_all_tests
  print 'clear'
  puts "Tests run #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  result_text = `rake spec`
  result = result_text.include? '0 failures'
  if not result
    `growlnotify --image spec/fail.jpeg -m 'Unit Tests Failed' Rspec`
	puts result_text
  else
    `growlnotify --image spec/success.png -m 'All Unit Tests Passed' Rspec`
	puts result_text
  end
end
 
watch('spec/(.*)\.rb')  {|md| run_all_tests }
watch('lib/(.*)\.rb')   {|md| run_all_tests }

puts "Watching..."

@interrupted = false
 
# Ctrl-C
Signal.trap "INT" do
  if @interrupted
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
 
    run_all_tests
    @interrupted = false
  end
end