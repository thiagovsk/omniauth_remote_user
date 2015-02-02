require File.dirname(__FILE__) + '/lib/omniauth-remote-user/version'

Gem::Specification.new do |gem|
  gem.add_runtime_dependency 'omniauth', '~> 1.0'
  gem.name = 'omniauth-remote-user'
  gem.version = Omniauth::RemoteUser::VERSION
  gem.description = 'Authentication with Remote-User HTTP header for Omniauth.'
  gem.summary = 'Authentication with HTTP Remote User'
  gem.email = ['kanashiro.duarte@gmail.com', 'thiagitosouza@gmail.com', 'rodrigosiqueiramelo@gmail.com','macartur.sc@gmail.com','terceiro@softwarelivre.org']
  gem.homepage = 'http://beta.softwarepublico.gov.br/gitlab/softwarepublico/omniauth-remote-user'
  gem.authors = ['Lucas Kanashiro', 'Thiago Ribeiro', 'Rodrigo Siqueira','Macartur Sousa', 'Antonio Terceiro']
  gem.require_paths = %w(lib)
  gem.files = `git ls-files -z`.split("\x0").reject {|f| f.start_with?('spec/')}
  gem.test_files = `git ls-files -- {test,spec,feature}/*`.split("\n")
  gem.license = "GPLv3"
  gem.required_rubygems_version = '>= 1.3.5'
end

