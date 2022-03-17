class CandidateAPISpecification
  CURRENT_VERSION = 'v1.1'.freeze
  VERSIONS = ['v1.1', 'v1.2'].freeze

  def self.as_yaml(version = CURRENT_VERSION)
    spec(version).to_yaml
  end

  def self.as_hash(version = CURRENT_VERSION)
    spec(version)
  end

  def self.spec(version = CURRENT_VERSION)
    YAML.load_file("config/candidate_api/#{version}.yml")
  end
end
