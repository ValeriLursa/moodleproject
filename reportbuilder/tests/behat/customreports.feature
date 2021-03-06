@core_reportbuilder @javascript
Feature: Manage custom reports
  In order to manage custom reports
  As an admin
  I need to create new and edit existing reports

  Scenario: Create custom report with default setup
    Given I log in as "admin"
    And I change window size to "large"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "New report" "button"
    And I set the following fields in the "New report" "dialogue" to these values:
      | Name                  | My report |
      | Report source         | Users     |
      | Include default setup | 1         |
    And I click on "Save" "button" in the "New report" "dialogue"
    Then I should see "My report"
    # Confirm we see the default columns in the report.
    And I should see "Full name" in the "reportbuilder-table" "table"
    And I should see "Username" in the "reportbuilder-table" "table"
    And I should see "Email address" in the "reportbuilder-table" "table"
    # Confirm we see the default conditions in the report.
    And I click on "Show/hide settings sidebar" "button"
    And I click on "Show/hide 'Conditions'" "button"
    Then I should see "Full name" in the "[data-region='settings-conditions']" "css_element"
    Then I should see "Username" in the "[data-region='settings-conditions']" "css_element"
    Then I should see "Email address" in the "[data-region='settings-conditions']" "css_element"
    # Confirm we see the default filters in the report.
    And I click on "Switch to preview mode" "button"
    And I click on "Filters" "button" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    Then I should see "Full name" in the "[data-region='report-filters']" "css_element"
    Then I should see "Username" in the "[data-region='report-filters']" "css_element"
    Then I should see "Email address" in the "[data-region='report-filters']" "css_element"
    And I navigate to "Reports > Report builder > Custom reports" in site administration
    And the following should exist in the "reportbuilder-table" table:
      | Name      | Report source | Modified by |
      | My report | Users         | Admin User  |

  Scenario: Create custom report without default setup
    Given I log in as "admin"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "New report" "button"
    And I set the following fields in the "New report" "dialogue" to these values:
      | Report source         | Users     |
      | Include default setup | 0         |
    # Try to set the report name to some blank spaces.
    And I set the field "Name" in the "New report" "dialogue" to "   "
    And I click on "Save" "button" in the "New report" "dialogue"
    And I should see "Required"
    And I set the field "Name" in the "New report" "dialogue" to "My report"
    And I click on "Save" "button" in the "New report" "dialogue"
    Then I should see "My report"
    And I should see "Nothing to display"
    And I navigate to "Reports > Report builder > Custom reports" in site administration
    And the following should exist in the "reportbuilder-table" table:
      | Name      | Report source |
      | My report | Users         |

  Scenario: Rename custom report
    Given the following "core_reportbuilder > Reports" exist:
      | name      | source                                   |
      | My report | core_user\reportbuilder\datasource\users |
    And I log in as "admin"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    # Try to set the report name to some blank spaces. It should simply ignore the change.
    And I set the field "Edit report name" in the "My report" "table_row" to "   "
    And I set the field "Edit report name" in the "My report" "table_row" to "My renamed report"
    And I reload the page
    Then the following should exist in the "reportbuilder-table" table:
      | Name              | Report source |
      | My renamed report | Users         |

  Scenario: Edit custom report from the custom reports page
    Given the following "core_reportbuilder > Reports" exist:
      | name      | source                                   |
      | My report | core_user\reportbuilder\datasource\users |
    And I log in as "admin"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "Edit report details" "link" in the "My report" "table_row"
    And I set the following fields in the "Edit report details" "dialogue" to these values:
      | Name | My renamed report |
    And I click on "Save" "button" in the "Edit report details" "dialogue"
    Then I should see "Report updated"
    And the following should exist in the "reportbuilder-table" table:
      | Name              | Report source |
      | My renamed report | Users         |

  Scenario Outline: Filter custom reports
    Given the following "core_reportbuilder > Reports" exist:
      | name       | source                                   |
      | My users   | core_user\reportbuilder\datasource\users |
    And I log in as "admin"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "Filters" "button"
    And I set the following fields in the "<filter>" "core_reportbuilder > Filter" to these values:
      | <filter> operator | Is equal to |
      | <filter> value    | <value>     |
    And I click on "Apply" "button" in the "[data-region='report-filters']" "css_element"
    Then I should see "Filters applied"
    And I should see "My users" in the "reportbuilder-table" "table"
    Examples:
      | filter        | value    |
      | Name          | My users |
      | Report source | Users    |

  Scenario: Delete custom report
    Given the following "core_reportbuilder > Reports" exist:
      | name      | source                                   |
      | My report | core_user\reportbuilder\datasource\users |
    And I log in as "admin"
    When I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "Delete report" "link" in the "My report" "table_row"
    And I click on "Delete" "button" in the "Delete report" "dialogue"
    Then I should see "Report deleted"
    And I should see "Nothing to display"

  Scenario: Switch between Preview and Edit mode
    Given the following "core_reportbuilder > Reports" exist:
      | name      | source                                   |
      | My report | core_user\reportbuilder\datasource\users |
    And I am on the "My report" "reportbuilder > Editor" page logged in as "admin"
    Then I should see "Preview" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should not see "Edit" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should see "Settings" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should not see "Filters" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should see "Full name" in the ".reportbuilder-sidebar-menu" "css_element"
    Then I click on "Switch to preview mode" "button"
    Then I should not see "Preview" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should see "Edit" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should not see "Settings" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should see "Filters" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    Then I click on "Switch to edit mode" "button"
    Then I should see "Preview" in the "[data-region='core_reportbuilder/report-header']" "css_element"
    And I should not see "Edit" in the "[data-region='core_reportbuilder/report-header']" "css_element"

  Scenario Outline: Access report clicking on the report name or view icon
    Given the following "core_reportbuilder > Reports" exist:
      | name      | source                                   |
      | My report | core_user\reportbuilder\datasource\users |
    When I log in as "admin"
    And I navigate to "Reports > Report builder > Custom reports" in site administration
    And I click on "<link>" "link" in the "My report" "table_row"
    Then <previewvisible> "Preview" in the "[data-region='core_reportbuilder/report']" "css_element"
    And <editvisible> "Edit" in the "[data-region='core_reportbuilder/report']" "css_element"
    And <settingsvisible> "Settings" in the "[data-region='core_reportbuilder/report']" "css_element"
    And <filtersvisible> "Filters" in the "[data-region='core_reportbuilder/report']" "css_element"
    Examples:
      | link       | previewvisible    | editvisible       | settingsvisible   | filtersvisible    |
      | My report  | I should see      | I should not see  | I should see      | I should not see  |
      | View       | I should not see  | I should not see  | I should not see  | I should see      |
