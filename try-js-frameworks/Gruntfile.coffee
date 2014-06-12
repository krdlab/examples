module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    browserify:
      dist:
        files:
          'app/vue/bundle.js': ['app/vue/home.js']
        options:
          transform: ['partialify']
    uglify:
      build:
        src: 'app/vue/bundle.js'
        dest: 'app/vue/bundle.min.js'
    watch:
      scripts:
        files: ['app/vue/home.js', 'app/vue/components/*']
        tasks: ['browserify', 'uglify']

  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['browserify', 'uglify']
  grunt.registerTask 'autobuild',   ['watch']
