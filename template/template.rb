$git_configuration_status = false 
$figaro_configuration_status = false
$bootstrap_configuration_status = false
$rspec_configuration_status = false
$foreman_configuration_status = false
$devise_configuration_status = false
$letter_opener_configuration_status = false

$status_time = Time.now
$username = nil
$password = nil

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gem_to_gem_file_in_group(group_str,&gem_block) 
  inject_into_file 'Gemfile', after: "#{group_str}\n", &gem_block
end

def add_gem_to_gem_file(&gem_block)
  inject_into_file 'Gemfile', after: "# gem 'capistrano-rails', group: :development\n", &gem_block  
end

def git_commit(message,time=0)
  if $git_configuration_status
    $status_time += (time*60)
    git add: "."
    git commit: "-a -m '#{message}' --date='#{$status_time.to_s}'"
  end
end

def default_configuration
  copy_file "app/assets/images/favicon.png"
  run "cp config/database.yml config/database.yml.sample"
  $username = ask("Username of database : ")
  $password = ask("Password of database : ")
  inject_into_file 'config/database.yml', after: "default: &default\n" do 
    "  username: #{$username}\n  password: #{$password}\n"
  end    
end

def git_configuration
  if yes?("Would you like to configure Git?")
    $git_configuration_status = true
    user_name = ask("What would you like use name in git config : ")
    user_email = ask("What would you like use email in git config : ")
    remove_file ".gitignore"
    copy_file "gitignore",".gitignore" 
    git :init
    git config: "user.name #{user_name}"
    git config: "user.email #{user_email}"
    git_commit("Initial Commit")
  end
end

def figaro_configuration
  if yes?("Would you like to configure Figaro?")
    $figaro_configuration_status = true
    add_gem_to_gem_file do <<-'RUBY' 
# configuration values often include sensitive information
gem 'figaro'

RUBY
    end
    after_bundle do
      template "config/application.yml.tmp", "config/application.yml"
      gsub_file 'config/application.yml', 'PRODUCTION_DATABASE_USERNAME', $username 
      gsub_file 'config/application.yml', 'PRODUCTION_DATABASE_PASSWORD', $password
      git_commit('Configure Figaro', 20)  
    end  
  end  
end

def bootstrap_configuration
  if yes?("Would you like to configure Bootstrap?")
    $bootstrap_configuration_status = true
    add_gem_to_gem_file do <<-'RUBY' 
# Add bootstrap into Rails with the asset pipeline.
gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'font-awesome-rails'

RUBY
    end
    after_bundle do  
      remove_file "app/assets/stylesheets/application.css"
      remove_file "app/views/layouts/application.html.erb"
      copy_file "app/assets/stylesheets/application.css.scss"
      remove_file "app/assets/javascripts/application.js"    
      copy_file "app/assets/javascripts/application.js"
      template "app/views/layouts/application.html.erb.tmp" ,"app/views/layouts/application.html.erb"
      gsub_file 'app/views/layouts/application.html.erb', '<%= yield %>', '<%= render "layouts/body_layout" %>'
      template "app/views/layouts/_body_layout.html.erb.tmp" ,"app/views/layouts/_body_layout.html.erb"
      template "app/views/layouts/_navigation.html.erb.tmp" ,"app/views/layouts/_navigation.html.erb"
      template "app/views/layouts/_header.html.erb.tmp" ,"app/views/layouts/_header.html.erb"
      template "app/views/layouts/_footer.html.erb.tmp" ,"app/views/layouts/_footer.html.erb"
      git_commit("Configure Bootstrap", 60)
    end  
  end
end

def rspec_configuration
  if yes?("Would you like to configure Rspec?")
    $rspec_configuration_status = true
    add_gem_to_gem_file_in_group("group :development, :test do") do <<-'RUBY' 
  # rspec-rails is a testing framework for rails.
  gem 'rspec-rails'

  RUBY
    end
    gem_group :test do
      gem 'factory_girl_rails'
      gem 'shoulda-matchers'
      gem 'faker'
      gem 'database_cleaner'
    end
    after_bundle do      
      copy_file "spec/rails_helper.rb"
      copy_file "spec/spec_helper.rb"
      copy_file "spec/support/request_spec_helper.rb"
      git_commit("Configure Rspec", 30)
    end
  end  
end

def foreman_configuration
  if yes?("Would you like to configure Foreman?")
    $foreman_configuration_status = true
    add_gem_to_gem_file do <<-'RUBY' 
# Using foreman you can declare the various processes that are needed to run your application
gem 'foreman'

RUBY
    end
    after_bundle do  
      copy_file "Procfile"
      copy_file "Procfile.dev"
      git_commit('Configure Foreman',10)
    end  
  end  
end

def devise_configuration
  if yes?("Would you like to configure Devise?")
    $devise_configuration_status = true
    add_gem_to_gem_file do <<-'RUBY' 
# Devise is a flexible authentication solution for Rails based on Warden
gem 'devise'

RUBY
    end
    after_bundle do 
      generate(:controller, "home index")
      route("root to: 'home#index'")
      environment('config.action_mailer.default_url_options = { host: "localhost", port: 3000 }', env: 'development')
      generate("devise:install")
      model_name = ask("What would you like the user model to be called? [user]")
      model_name = "user" if model_name.blank?
      generate("devise", model_name)
      template "app/views/layouts/_devise_navigation.html.erb.tmp" ,"app/views/layouts/_devise_navigation.html.erb"
      gsub_file 'app/views/layouts/_devise_navigation.html.erb', 'devise_resource', model_name.to_s.downcase
      gsub_file 'app/views/layouts/_navigation.html.erb', '<ul class="nav navbar-nav navbar-right"></ul>', '<%= render "layouts/devise_navigation" %>'
      remove_file "app/helpers/application_helper.rb"
      copy_file "app/helpers/application_helper.rb"
      directory "app/views/devise", "app/views/devise", :recursive => true
      git_commit('Configure Devise', 120)
    end  
  end  
end

def letter_opener_configuration
  if yes?("Would you like to configure Letter Opener?")
    $letter_opener_configuration_status = true
    add_gem_to_gem_file_in_group("group :development do") do <<-'RUBY' 
  # Preview email in the default browser instead of sending it.
  gem 'letter_opener'

  RUBY
    end
    after_bundle do
      inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do <<-'RUBY' 
  config.action_mailer.delivery_method = :letter_opener    
    RUBY
      end
      git_commit("Configure Letter Opener", 30)
    end
  end  
end

def react_configuration
  if yes?("Would you like to configure React?")
    template "app/javascript/packs/body_layout.jsx.tmp" ,"app/javascript/packs/body_layout.jsx" 
    template "app/javascript/packs/footer.jsx.tmp" ,"app/javascript/packs/footer.jsx"
    template "app/javascript/packs/header.jsx.tmp" ,"app/javascript/packs/header.jsx"
    template "app/javascript/packs/navigation.jsx.tmp" ,"app/javascript/packs/navigation.jsx"

    if $devise_configuration_status
      inject_into_file 'app/javascript/packs/navigation.jsx', after: "import React from 'react'\n" do <<-'RUBY' 
        import DeviseNavigation from './devise_navigation.jsx';    
      RUBY
        end
      gsub_file 'app/javascript/packs/navigation.jsx', '<ul class="nav navbar-nav navbar-right"></ul>', '<DeviseNavigation/>'
      template "app/javascript/packs/devise_navigation.jsx.tmp" ,"app/javascript/packs/devise_navigation.jsx"
    end
  end
end


def finale_configuration
  after_bundle do
    rake "db:drop"
    rake "db:create"
    rake "db:migrate"
    rake "db:test:prepare"    
    rake "db:seed"
  end
end

# Configure defaults
default_configuration

# Configure git
git_configuration

# Configure figaro
figaro_configuration

# Configure bootstrap
bootstrap_configuration

# Configure rspec
rspec_configuration

# Configure foreman
foreman_configuration

# Configure devise
devise_configuration

# Configure letter opener
letter_opener_configuration

# Configure letter opener
react_configuration

# Configure finale
finale_configuration
