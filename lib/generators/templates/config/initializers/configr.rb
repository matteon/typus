default_configuration     = YAML.load(File.open(Rails.root.join('config', 'configr.yml'))) || {}
environment_configuration = YAML.load(File.open(Rails.root.join('config', 'environments', "#{Rails.env}.yml"))) || {}
AppConfig = Configr::Configuration.configure(YAML.dump(default_configuration.merge(environment_configuration)))