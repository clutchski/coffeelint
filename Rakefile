
desc "Update the CoffeeScript Javascript."
task :update do
  sh("git show master:src/coffeelint.coffee | node_modules/.bin/coffee --stdio --print > js/coffeelint.js")
end
