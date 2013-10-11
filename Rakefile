
desc "Update the CoffeeScript Javascript."
task :update do
  # sh("git show master:src/coffeelint.coffee | node_modules/.bin/coffee --stdio --print > js/coffeelint.js")
  puts "WARNING: 'rake update' does not update coffeelint.js any more."
  puts "It has to be done manually before running rake update"
  puts ""
  puts "git checkout master &&"
  puts "npm run compile &&"
  puts "git checkout gh-pages &&"
  puts "cp lib/coffeelint.js js/coffeelint.js &&"
  puts "rake updatehtml"
end

task :updatehtml do
  sh("git show master:src/htmldoc.coffee > js/htmldoc.coffee && cat index-top.html > new_index.html && node_modules/.bin/coffee js/htmldoc.coffee >> new_index.html && cat index-bottom.html >> new_index.html && mv new_index.html index.html && rm js/htmldoc.coffee")
end
