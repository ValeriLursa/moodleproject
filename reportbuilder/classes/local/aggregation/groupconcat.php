<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

declare(strict_types=1);

namespace core_reportbuilder\local\aggregation;

use lang_string;
use core_reportbuilder\local\helpers\database;
use core_reportbuilder\local\report\column;

/**
 * Column group concatenation aggregation type
 *
 * @package     core_reportbuilder
 * @copyright   2021 Paul Holden <paulh@moodle.com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class groupconcat extends base {

    /** @var string Character to use as a delimeter between column fields */
    protected const COLUMN_FIELD_DELIMETER = '<|>';

    /** @var string Character to use as a delimeter between field values */
    protected const FIELD_VALUE_DELIMETER = '<,>';

    /**
     * Return aggregation name
     *
     * @return lang_string
     */
    public static function get_name(): lang_string {
        return new lang_string('aggregationgroupconcat', 'core_reportbuilder');
    }

    /**
     * This aggregation can be performed on all non-timestamp columns
     *
     * @param int $columntype
     * @return bool
     */
    public static function compatible(int $columntype): bool {
        return !in_array($columntype, [
            column::TYPE_TIMESTAMP,
        ]);
    }

    /**
     * We cannot sort this aggregation type
     *
     * @param bool $columnsortable
     * @return bool
     */
    public static function sortable(bool $columnsortable): bool {
        return false;
    }

    /**
     * Override base method to ensure all SQL fields are concatenated together if there are multiple
     *
     * @param array $sqlfields
     * @return string
     */
    public static function get_column_field_sql(array $sqlfields): string {
        global $DB;

        if (count($sqlfields) === 1) {
            return parent::get_column_field_sql($sqlfields);
        }

        // Coalesce all the SQL fields, to remove all nulls.
        $concatfields = [];
        foreach ($sqlfields as $sqlfield) {

            // We need to ensure all values are char (this ought to be done in the DML drivers, see MDL-72184).
            switch ($DB->get_dbfamily()) {
                case 'postgres' :
                    $sqlfield = "CAST({$sqlfield} AS VARCHAR)";
                break;
                case 'oracle' :
                    $sqlfield = "TO_CHAR({$sqlfield})";
                break;
            }

            $concatfields[] = "COALESCE({$sqlfield}, ' ')";
            $concatfields[] = "'" . self::COLUMN_FIELD_DELIMETER . "'";
        }

        // Slice off the last delimeter.
        return $DB->sql_concat(...array_slice($concatfields, 0, -1));
    }

    /**
     * Return the aggregated field SQL
     *
     * @param string $field
     * @param int $columntype
     * @return string
     */
    public static function get_field_sql(string $field, int $columntype): string {
        global $DB;

        $fieldsort = database::sql_group_concat_sort($field);

        return $DB->sql_group_concat($field, self::FIELD_VALUE_DELIMETER, $fieldsort);
    }

    /**
     * Return formatted value for column when applying aggregation, note we need to split apart the concatenated string
     * and apply callbacks to each concatenated value separately
     *
     * @param mixed $value
     * @param array $values
     * @param array $callbacks
     * @return mixed
     */
    public static function format_value($value, array $values, array $callbacks) {
        $formattedvalues = [];

        // Store original names of all values that would be present without aggregation.
        $valuenames = array_keys($values);
        $values = explode(self::FIELD_VALUE_DELIMETER, (string) reset($values));

        // Loop over each extracted value from the concatenated string.
        foreach ($values as $value) {
            $originalvalue = array_combine($valuenames, explode(self::COLUMN_FIELD_DELIMETER, $value));
            $originalfirstvalue = reset($originalvalue);

            // Once we've re-constructed each value, we can apply callbacks to it.
            $formattedvalues[] = parent::format_value($originalfirstvalue, $originalvalue, $callbacks);
        }

        return implode(', ', $formattedvalues);
    }
}
