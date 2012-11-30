{exec} = require "child_process"

task "build", "Build src/*.coffee to dist/*.js", (cb) ->
  exec "coffee --compile --output dist/ src/", (err, stdout, stderr) ->
    throw err if err
    console.log "success"