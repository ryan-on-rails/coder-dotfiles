#!/bin/bash

# Logic: Attempts 'bundle exec' first if a Gemfile exists and ruby-lsp is in the bundle.
# Fallback: If Gemfile exists but ruby-lsp is excluded/missing, or if no Gemfile exists,
# it checks for a global installation via asdf. If global gem is missing, it installs it.

RUBY_LSP_NAME="ruby-lsp"

error_msg() {
    echo "--- ${RUBY_LSP_NAME} ERROR ---" >&2
    echo "$1" >&2
    echo "---------------------------" >&2
}

launch_global_or_install() {
    if command -v "$RUBY_LSP_NAME" > /dev/null 2>&1; then
        error_msg "Launching unbundled LSP via 'asdf exec'."
        exec asdf exec "$RUBY_LSP_NAME" "$@"
    fi
    
    error_msg "The '${RUBY_LSP_NAME}' gem is missing for this Ruby version."
    error_msg "Action: Attempting to automatically run 'gem install ${RUBY_LSP_NAME}' now..."

    if ! asdf exec gem install "$RUBY_LSP_NAME" --no-document; then
        error_msg "FATAL: 'gem install' failed. Check your global Ruby environment and permissions."
        exit 1
    fi
    
    error_msg "Gem install successful. Launching LSP."
    exec asdf exec "$RUBY_LSP_NAME" "$@"
}

if [ -f "./Gemfile" ]; then
    if ! bundle check > /dev/null 2>&1; then
        error_msg "Project dependencies are missing. Please run 'bundle install' in the project root."
        exit 1
    fi
    
    if bundle info "$RUBY_LSP_NAME" > /dev/null 2>&1; then
        error_msg "Launching bundled LSP via 'bundle exec'."
        exec bundle exec "$RUBY_LSP_NAME" "$@"
    else
        error_msg "Project Gemfile exists, but '${RUBY_LSP_NAME}' is not included in the bundle."
        launch_global_or_install "$@"
    fi
else
    error_msg "No Gemfile found. Falling back to global LSP."
    launch_global_or_install "$@"
fi
