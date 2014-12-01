# For custom domains on github pages
page "CNAME", layout: false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

sprockets.append_path File.join root, 'bower_components'

# sprockets.import_asset 'jquery'
sprockets.import_asset 'angular'
sprockets.import_asset 'hammerjs'
sprockets.import_asset 'angular-aria'
sprockets.import_asset 'angular-animate'
sprockets.import_asset 'angular-material'
sprockets.import_asset 'angular-route'
sprockets.import_asset 'weather-icons'

# Dir.glob( 'bower_components/weather-icons/fonts/*' ).each do |file|
#   file.gsub!( /bower_components\//, "" )
#   puts file

#   sprockets.import_asset file do |f|
#     new_file =  file.gsub( /weather-icons\//, "" )
#     puts new_file
#     new_file
#   end
# end

# Better markdown support
# set :markdown, :tables => true, :autolink => true, :gh_blockcode => true, :fenced_code_blocks => true
# set :markdown_engine, :redcarpet

activate :autometatags

# Turn this on if you want to make your url's prettier, without the .html
# activate :directory_indexes

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Easier bootstrap navbars
# activate :bootstrap_navbar

configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
  # Any files you want to ignore:
  ignore '/admin/*'
  ignore '/stylesheets/admin/*'

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/blog/"
end


# This will push to the gh-pages branch of the repo, which will
# host it on github pages (If this is a github repository)
activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
end
