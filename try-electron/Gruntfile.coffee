module.exports = (grunt) ->
  require('load-grunt-tasks') grunt

  deps = (grunt.file.readJSON 'package.json').dependencies
  includes = (k + '/**/*' for k, v of deps)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    copy:
      dist:
        files: [
          {
            cwd: 'src'
            expand: true
            src: ['*.*']
            dest: 'app'
          },
          {
            cwd: '.'
            src: 'package.json'
            dest: 'app/package.json'
          },
          {
            cwd: 'node_modules'
            expand: true
            src: includes
            dest: 'app/node_modules'
          }
        ]
    watch:
      options:
        livereload: true
      scripts:
        files: [
          'src/*.*'
        ]
        tasks: ['copy']
    electron:
      options:
        name: '<%= pkg.name %>'
        dir: 'app'
        version: '0.29.1'
      linux:
        options:
          platform: 'linux'
          arch: 'x64'
          out: 'dist/linux'
    clean: ['dist/*']

  grunt.registerTask 'default', ['copy']
  grunt.registerTask 'autobuild', ['watch']
  grunt.registerTask 'package', ['copy', 'clean', 'electron']
