module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    purescript:
      options:
        magicDo: true
        tco: true
        main: false
      build:
        src: ['src/**/*.purs', 'bower_components/purescript-*/**/*.purs', 'bower_components/purescript-*/**/*.purs.hs']
        dest: 'dst/<%= pkg.name %>.js'
    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      build:
        src: 'dst/<%= pkg.name %>.js'
        dest: 'app/scripts/<%= pkg.name %>.min.js'
    connect:
      options:
        port: 9000
        hostname: 'localhost'
        livereload: true
      app:
        options:
          open: false
          base: 'app'
    watch:
      options: '<%= connect.options.livereload %>'
      html:
        files:  '<%= connect.app.options.base %>'

  grunt.loadNpmTasks 'grunt-purescript'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['purescript', 'uglify']
  grunt.registerTask 'server', ['connect', 'watch']
