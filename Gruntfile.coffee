module.exports = (grunt) ->
	"use strict"

	grunt.initConfig
		###
		uglify : 
			dist : 
				src :  'public/js/main.js'
				dest : 'public/js/main.min.js'
		###

		watch :
			dev :
				files : [
					'client_src/coffee/**.coffee', 
					'client_src/sass/**.sass',
					'views/*',
					'app.coffee']
				tasks : ['build']
				options : 
					livereload : true

		compass : 
			dev :
				options : 
					#config : 'client_src/config.rb'
					sassDir : 'client_src/sass'
					cssDir : 'public/css'

		coffee : 
			compile :
				options :
					#bare : true
					join : true
				files :
					#'public/js/main.js' : 'client_src/coffee/main.coffee'
					'public/js/app.js' : [
						'client_src/coffee/gallery-app.coffee'
						'client_src/coffee/services.coffee'
						'client_src/coffee/controllers2.coffee'
						'client_src/coffee/directives2.coffee'
						'client_src/coffee/filters.coffee'
					]

		###
		nodemon : 
			dev : 
				options : 
					file : 'app.coffee'
					args : ['development']
		###


	#grunt.loadNpmTasks('grunt-contrib-uglify')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-contrib-compass')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	#grunt.loadNpmTasks('grunt-nodemon')

	grunt.registerTask('build', ['compass:dev', 'coffee:compile'])