# Objectives 🎯

To run `rissk`, one must execute Python. For many DECSU workflows, one is using Stata. To reduce friction, this repository:

- Explains how to set up rissk on your system
- Provides Stata `.do` files for running `rissk` without leaving Stata

# Installation 🔌

For initial setup, there are 3 dependencies to "install":

1. [Python](#python)
1. [`rissk`](#rissk)
1. [Stata `.do` files](#stata-do-files)

## Python

Install Python from Company Portal:

- Open `Company Portal` from the Windows start menu
- Search `Python`
- Click to the `Install` to install

If questions or problems arise, contact ITS for support.

## `rissk`

First, download a copy of `rissk` for your project. To do so, follow steps 1 and 2 [here](https://github.com/worldbank/rissk#setup).

Then, install `uv` (as a Python package). To do so:

- Open `Powershell`
- Run the `pip install uv` in `Powershell`.

Next, still in `Powershell`, run the following (providing your rissk path after `cd` intead of the placeholder):

```powershell
# change your directory to the one where you installed rissk in the first
# step in this section
cd "C:/where/you/downloaded/rissk"

# create a virtual environment with a specific version of Python
uv venv --python 3.11

# pin that version for the project
uv python pin 3.11

# activate the virtual environment
# for Powershell on Windows
.venv/Scripts/activate

# install the requirements, importantly, having `uv` control which Python version does this
uv pip install -r requirements.txt
```

## Stata `.do` files

Download the Stata `.do` files in this repository to the place where you will be running them.

Note: they do not need to be in the place where you downloaded risk. However, these two `.do` files do need to be co-located in the same directory, since `run_rissk.do` calls `remove_timestamp_in_names.do`.

Here's what each script does:

- `run_rissk.do`, as its name suggests, runs rissk, with some pre-flight checks (e.g., user-provided directories exist) and pre-execution preparation of inputs (i.e., rename `*.zip` files, if needed, to meet `rissk`'s expectations)
- `remove_timestamp_in_names`.do provides a utility function to rename zip export files, since `rissk` assumes that export files follow a certain name format but Survey Solutions recently changed that format. See more [here](https://github.com/worldbank/rissk/issues/30).

# Usage 👩‍💻

## Initial setup ⚙️

Because `run_rissk.do` needs your directory paths to run, provide them in macros at the top of the file:

```stata
* ============================================================
* provide user paths
* ============================================================

local curr_dir ""
local project_dir ""
local input_dir  ""
local output_file "`input_dir'/output.csv"
```

This is how to understand each path:

- **`curr_dir`.** Directory where `run_rissk.do` and `remove_timestamp_in_names.do` are co-located and from which `run_rissk.do` is run.
- **`project_dir`.** Directory where you have copied `rissk`.
- **`input_dir`.** Directory where the `*.zip` files required by `rissk`--that is, the microdata and paradata--are located.
- **`output_file`.** Path to where you want `rissk` to output its scores. Note: you may change the file name (`output`), but not its extension (`.csv`).

## Daily usage 💻

During routine usage, the user will need to undertake two actions:

1. **Provided data.** The program runs against data found in `input_dir`. The user will need to provide new data, whether that is through moving files manually or automatically with a script (e.g., Stata's `copy` command).
2. **Run `run_rissk.do`.** Do as you would any other Stata script. This may be done either as part of a larger pipeline or as a standalone operation.