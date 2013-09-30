@disable-bundler
Feature: run a rake task through several appraisals

  Background:
    Given a directory named "projecto"
    And the following installed dummy gems:
      | name       | version |
      | dummy_girl | 1.3.0   |
      | dummy_girl | 1.3.2   |
      | dummy_rake | 0.8.7   |
      | dummy_rake | 0.9.0   |
      | dummy_sass | 3.1.0   |
      | dummy_spec | 3.1.9   |
    When I cd to "projecto"
    And I write to "Gemfile" with:
    """
    gem "dummy_rake", "0.8.7"
    gem "dummy_girl"

    group :assets do
      gem 'dummy_sass', "~> 3.1.0"
    end

    group :test, :development do
      gem 'dummy_spec', "~> 3.1.0"
    end
    """
    When I add "appraisal" from this project as a dependency
    And I write to "Appraisals" with:
    """
    appraise "1.3.2" do
      gem "dummy_girl", "1.3.2"
    end

    appraise "1.3.0" do
      gem "dummy_girl", "1.3.0"
      gem "dummy_rake", "0.9.0"
    end
    """
    When I write to "Rakefile" with:
    """
    require 'rubygems'
    require 'bundler/setup'
    require 'appraisal'

    task :version do
      require 'dummy_girl'
      puts "Loaded #{$dummy_girl_version}"
    end

    task :fail do
      require 'dummy_girl'
      puts "Fail #{$dummy_girl_version}"
      raise
    end

    task :default => :version
    """
    When I successfully run `bundle install --local`
    And I successfully run `bundle exec rake appraisal:install --trace`

  Scenario: install gems within groups
    Then the file "gemfiles/1.3.0.gemfile" should contain:
      """
      group :assets do
        gem "dummy_sass", "~> 3.1.0"
      end
      """
