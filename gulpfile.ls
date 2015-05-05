# Load all required libraries.
gulp       = require \gulp
livereload = require \gulp-livereload
nodemon = require \gulp-nodemon

gulp.task 'watch', ->
  livereload.listen!

gulp.task \develop, ->
    nodemon {        
        exec-map: ls: \lsc
        ext: \ls
        ignore: <[public/*]>
        script: \./server.ls
    }

gulp.task 'default', <[watch develop]>