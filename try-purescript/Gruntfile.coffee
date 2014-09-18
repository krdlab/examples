module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    libs: [
      'bower_components/purescript-*/**/*.purs',
      'bower_components/purescript-*/**/*.purs.hs'
    ]
    psc:
      build:
        options:
          main: true
          modules: "Main"
        src: ['<%= grunt.cli.options.src %>', '<%= libs %>']
        dest: 'dst/index.js'
    clean:
      build: ["dst"]
    execute:
      dest:
        src: ['dst/index.js']

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'default', ['clean', 'psc']
  grunt.registerTask 'run', ['execute']
