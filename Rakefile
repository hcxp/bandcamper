require 'rake'
require 'hanami/rake_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end

task db_seed: :environment do
  bands_repo = BandRepository.new

  bands_repo.create(name: 'Regres', guid: 'regres')
  bands_repo.create(name: 'Vicious X Reality', guid: 'viciousxreality')
end
