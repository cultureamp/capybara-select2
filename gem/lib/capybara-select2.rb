require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) and [:from, :xpath, :css].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = find(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = find(:css, options[:css])
      else
        select_name = options[:from]
        select2_container = find("label", text: select_name).find(:xpath, '..').find(".select2-container")
      end

      # Open select2 field
      select2_container.first(".select2-selection, .select2-choice, .select2-choices").click

      body = find(:xpath, "//body")

      if options.has_key? :search
        body.find(".select2-search input.select2-search__field").set(value)
        page.execute_script(%|$("input.select2-search__field:visible").keyup();|)
        drop_container = body.find(".select2-results")
      else
        drop_container = body.first(".select2-dropdown, .select2-drop")
      end

      [value].flatten.each do |value|
        drop_container.first("li.select2-results__option, li.select2-result-selectable", text: value).click
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
