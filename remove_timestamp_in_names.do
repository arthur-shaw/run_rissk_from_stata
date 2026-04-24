* ===========================================================================
* remove_timestamp_in_names.do
*
* Defines the program `remove_timestamp_in_names`, which renames .zip files
* in a given directory by removing the trailing timestamp component.
*
* Pattern matched: _<8 digits>T<4 digits>Z  (e.g., _20260418T1800Z)
* Example:
*   Before: BANGLADESH_PILOT_R0_1_STATA_All_20260418T1800Z.zip
*   After:  BANGLADESH_PILOT_R0_1_STATA_All.zip
*
* Syntax:
*   remove_timestamp_in_names , dir(string) [dry_run]
*
* Options:
*   dir(string)   Path to the folder containing .zip files to rename.
*   dry_run       Display proposed renames without making any changes.
*
* Examples:
*   remove_timestamp_in_names, dir("C:/data/exports")
*   remove_timestamp_in_names, dir("C:/data/exports") dry_run
* ===========================================================================

capture program drop remove_timestamp_in_names
program define remove_timestamp_in_names

    * -------------------------------------------------------------------------
    * Syntax: required dir() option, optional dry_run flag
    * -------------------------------------------------------------------------
    syntax , dir(string) [dry_run]

    * Resolve dry_run to a 0/1 indicator
    local is_dry_run = ("`dry_run'" == "dry_run")

    * -------------------------------------------------------------------------
    * Validate directory
    * -------------------------------------------------------------------------
    * Use Mata's direxists() because on Windows fileexists() returns 0 for
    * directories -- only direxists() reliably distinguishes a directory from
    * a file on all platforms.
    mata: st_local("dir_ok", strofreal(direxists(st_local("dir"))))

    if !`dir_ok' {
        di as error "Directory not found: `dir'"
        exit 601
    }

    * -------------------------------------------------------------------------
    * Collect files and rename
    * -------------------------------------------------------------------------
    local pattern "_[0-9]{8}T[0-9]{4}Z"

    local files : dir `"`dir'"' files "*.zip", respectcase

    if `"`files'"' == "" {
        di as error "No .zip files found in: `dir'"
        exit 0
    }

    if `is_dry_run' {
        di as text "[DRY RUN] No files will be changed."
        di as text ""
    }

    local n_renamed  = 0
    local n_skipped  = 0
    local n_no_match = 0

    foreach fname of local files {

        local has_match = ustrregexm(`"`fname'"', `"`pattern'"')

        if `has_match' {

            local newname = ustrregexra(`"`fname'"', `"`pattern'"', "")

            local src `"`dir'/`fname'"'
            local dst `"`dir'/`newname'"'

            if `is_dry_run' {
                di as text "  `fname'"
                di as text "    -> `newname'"
            }
            else {
                if fileexists(`"`dst'"') {
                    di as error "WARNING: target exists, skipping: `newname'"
                    local ++n_skipped
                    continue
                }

                shell rename `"`src'"' `"`newname'"'
                di as result "Renamed: `fname' -> `newname'"
                local ++n_renamed
            }

        }
        else {
            di as text "No timestamp found, skipping: `fname'"
            local ++n_no_match
        }
    }

    * -------------------------------------------------------------------------
    * Summary
    * -------------------------------------------------------------------------
    di ""
    if `is_dry_run' {
        di as text "--- DRY RUN complete (no files were changed) ---"
    }
    else {
        di as text "--- Done ---"
        di as text "  Renamed:                  `n_renamed'"
        di as text "  Skipped (target exists):  `n_skipped'"
        di as text "  Skipped (no match):       `n_no_match'"
    }

end
