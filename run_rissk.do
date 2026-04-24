* ============================================================
* provide user paths
* ============================================================

local curr_dir ""
local project_dir ""
local input_dir  ""
local output_file "`input_dir'/output.csv"

* ============================================================
* confirm user-provided paramters
* ============================================================

* ------------------------------------------------------------
* confirm directories exist
* ------------------------------------------------------------

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* current directory
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

mata: st_local("curr_dir_ok", strofreal(direxists(st_local("project_dir"))))

if !`curr_dir_ok' {
    di as error "Directory not found: `curr_dir'"
    exit 601
}

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* project directory
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

mata: st_local("proj_dir_ok", strofreal(direxists(st_local("project_dir"))))

if !`proj_dir_ok' {
    di as error "Directory not found: `project_dir'"
    exit 601
}

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
* input directory
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

mata: st_local("input_dir_ok", strofreal(direxists(st_local("input_dir"))))

if !`input_dir_ok' {
    di as error "Directory not found: `input_dir'"
    exit 601
}

* ------------------------------------------------------------
* confirm zip files are present in input directory
* ------------------------------------------------------------

local zip_files_list : dir "`input_dir'" files "*.zip", respectcase
local zip_files_exist : list sizeof zip_files_list

capture assert `zip_files_exist' == 1
if _rc != 0 {
  di as error "No zip files found in `input_dir'"
  exit 9
}

* ============================================================
* remove timestamp from names zip files
* motivation: https://github.com/worldbank/rissk/issues/30
* ============================================================

* confirm that `remove_timestamp_in_names.do` is present


* load program definition into session
include "`curr_dir'/remove_timestamp_in_names.do"

* run program to rename zip files on disk
remove_timestamp_in_names, dir("`input_dir'")

* ============================================================
* run `rissk` workflow
* ============================================================

* ------------------------------------------------------------
* construct paths
* ------------------------------------------------------------

local venv_python_exe  "`project_dir'/.venv/main_scripts/python.exe"
local main_script      "`project_dir'/main.py"

* ------------------------------------------------------------
* confirm Python virtual environment exists
* ------------------------------------------------------------

* Confirm the venv Python exists before attempting execution
capture confirm file "`venv_python_exe'"
if _rc != 0 {
    display as error "Python virtual environment not found at: `venv_python_exe'"
    display as error "Has the uv environment been created?"
    exit 601
}

* ------------------------------------------------------------
* 
* ------------------------------------------------------------

display "Running: `venv_python_exe' `main_script'"
display "  export_path=`input_dir'"
display "  output_file=`output_file'"

shell "`venv_python_exe'" ///
  "`main_script'" ///
  export_path="`input_dir'" ///
  output_file="`output_file'" ///
  survey_version=all ///
  feature_score=true ///
    
display "Python script completed with return code: `=_rc'"
