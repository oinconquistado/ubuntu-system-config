# Display time
SPACESHIP_TIME_SHOW=true

# Display username always
SPACESHIP_USER_SHOW=always

# Do not truncate path in repos
SPACESHIP_DIR_TRUNC_REPO=false

SPACESHIP_TIME_COLOR=242
SPACESHIP_USER_COLOR=199
SPACESHIP_HOST_COLOR=242
SPACESHIP_DIR_COLOR=141
SPACESHIP_GIT_BRANCH_COLOR=211


SPACESHIP_CHAR_SYMBOL_ROOT="🚀"

SPACESHIP_TIME_PREFIX="\e[38;5;242m("
SPACESHIP_TIME_SUFFIX="\e[38;5;242m)"

SPACESHIP_USER_PREFIX="" # remove `with` before username
SPACESHIP_USER_SUFFIX=" " # remove space before host

SPACESHIP_DIR_PREFIX='at ' # disable directory prefix, cause it's not the first section
SPACESHIP_DIR_TRUNC='1' # show only last directory

SPACESHIP_GIT_STATUS_ADDED="added"
SPACESHIP_GIT_STATUS_MODIFIED="unstaged"
SPACESHIP_GIT_STATUS_RENAMED="renamed"
SPACESHIP_GIT_STATUS_DELETED="deleted"
SPACESHIP_GIT_STATUS_STASHED="stashed"
SPACESHIP_GIT_STATUS_UNMERGED="unmerged"
SPACESHIP_GIT_STATUS_AHEAD="ahead"
SPACESHIP_GIT_STATUS_DIVERGED="diverged"
SPACESHIP_GIT_STATUS_BEHIND="behind"
SPACESHIP_GIT_STATUS_UNTRACKED="untracked"



# Add a custom vi-mode section to the prompt
# See: https://github.com/spaceship-prompt/spaceship-vi-mode
spaceship add --before char vi_mode

# Add custom sections
spaceship add react
spaceship add flutter
spaceship add vue
spaceship add gradle

SPACESHIP_PROMPT_ORDER=(sudo user host dir react flutter vue gradle dart python node docker package git exit_code time line_sep char)
