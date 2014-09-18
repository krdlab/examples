module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    libs: [
      'bower_components/purescript-*/src/**/*.purs'
    ]
    psc:
      build:
        options:
          main: true
          modules: "Main"
        src: ['<%= grunt.cli.options.src %>', '<%= libs %>']
        dest: 'dst/index.js'
    dotPsci: ['<%= libs %>']
    clean:
      build: ["dst"]
    execute:
      dest:
        src: ['dst/index.js']

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'default', ['clean', 'psc', 'dotPsci']
  grunt.registerTask 'run', ['execute']
