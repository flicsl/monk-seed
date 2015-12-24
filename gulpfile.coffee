outline = require './outline.json'

gulp = require 'gulp'
jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
templateCache = require 'gulp-angular-templatecache';
plumber = require 'gulp-plumber'
browserSync = require 'browser-sync'
reload = browserSync.reload
bowerFiles = require 'main-bower-files'
inject = require 'gulp-inject'
ngAnnotate = require 'gulp-ng-annotate'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
watch = require 'gulp-watch'

paths = 
	coffee: "#{outline.src}/**/*.coffee"
	sass: "#{outline.src}/**/*.scss"
	jade: "#{outline.src}/**/*.jade"
	assets: "#{outline.src}/assets/"

gulp.task 'browser-sync', ->
	browserSync server: baseDir: outline.dist

gulp.task 'index', ->
	gulp.src "#{outline.src}/index.jade"
		.pipe plumber()
		.pipe jade()
		.pipe inject(gulp.src(bowerFiles()), {name: 'bower', addRootSlash: false, ignorePath: "/#{outline.dist}"})
		.pipe gulp.dest("#{outline.dist}")

gulp.task 'jade', ['index'], ->
	gulp.src [paths.jade, '!**/*/index.jade']
		.pipe plumber()
		.pipe jade(pretty : true)
		.pipe templateCache({standalone: true})
		.pipe gulp.dest("#{outline.dist}/js")

gulp.task 'sass', ->
	gulp.src [paths.sass]
		.pipe sass(outputStyle: 'compressed')
		.pipe concat("#{outline.name}.min.css")
		.pipe gulp.dest("#{outline.dist}/css")
		.pipe reload(stream : true)

gulp.task 'coffee', ->
	gulp.src paths.coffee
		.pipe plumber()
		.pipe coffee()
		.pipe concat("#{outline.name}.min.js")
		.pipe ngAnnotate()
		.pipe uglify()
		.pipe gulp.dest("#{outline.dist}/js")
		.pipe reload(stream : true)

gulp.task 'assets', ->
	gulp.src paths.assets
		.pipe gulp.dest("#{outline.dist}")

gulp.task 'watch', ->
	watch paths.sass, -> gulp.start 'sass'
	watch paths.jade, -> gulp.start 'jade'
	watch paths.coffee, -> gulp.start 'coffee'
	watch "#{paths.assets}/**/*", -> gulp.start 'assets'

gulp.task 'build', ['assets', 'jade', 'coffee', 'sass']
gulp.task 'default', ['build', 'browser-sync']