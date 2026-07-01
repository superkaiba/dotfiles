# Claude Code bash aliases — mirrors zsh wrapper in config/zsh/zshrc.sh
#
# `claude` launches Happy (happy.engineering), which wraps Claude Code.
# Defaults: --model opus[1m] (Opus 4.7, 1M context), --effort xhigh.
# Settings.json also pins model+effort globally; passing them on the CLI is
# belt-and-suspenders (effort historically doesn't persist via JSON, and we
# want the alias to be self-describing).
#
# Escape hatches for the raw claude CLI: `command claude`, `\claude`,
# or the full path `$HOME/.local/bin/claude`.

# Auto-wrap `claude` in tmux so the session survives SSH disconnects / laptop
# close. Each invocation spawns its own session named cc-<pwd>-<N>
# (N = lowest unused), so multiple concurrent claudes in the same directory
# coexist. Reattach with `tmux a -t <name>`; list with `claude-ls`.
# Already inside tmux → skip wrapping (no nested tmux).
claude() {
    if [[ -n "$TMUX" ]]; then
        happy claude --model 'opus[1m]' --effort xhigh "$@"
        return
    fi
    local base
    base="cc-$(basename "$PWD")"
    base="${base//[^A-Za-z0-9_-]/_}"
    local n=1
    while tmux has-session -t "${base}-${n}" 2>/dev/null; do
        ((n++))
    done
    # printf %q-quotes each arg so tmux new-session gets one shell-safe string
    local quoted_args=""
    if (( $# > 0 )); then
        quoted_args=" $(printf '%q ' "$@")"
    fi
    tmux new-session -s "${base}-${n}" "happy claude --model 'opus[1m]' --effort xhigh${quoted_args}"
}

# List running claude tmux sessions.
claude-ls() { tmux ls 2>/dev/null | grep -E '^cc-' || echo "no running claude sessions"; }

# Variants that bypass Happy and invoke the raw Claude Code CLI directly.
alias claude_remote='unset ANTHROPIC_API_KEY && command claude'
alias claude_api='ANTHROPIC_API_KEY=$(cat ~/.claude/.api-key) command claude'

# tmux has no native "description" field, so we stash one in a per-session user
# option (@description). `tls` lists sessions with it; `tdesc` sets it.

# Set a human-readable description on a tmux session.
#   tdesc "note"             -> current session (must be run inside tmux)
#   tdesc <session> "note"   -> named session
# An empty note clears the description:  tdesc ""   /   tdesc <session> ""
tdesc() {
    local note
    if [[ $# -eq 1 ]]; then
        [[ -z "$TMUX" ]] && { echo 'tdesc: not inside tmux; use: tdesc <session> "note"' >&2; return 2; }
        note="$1"
        if [[ -z "$note" ]]; then tmux set-option -u @description
        else tmux set-option @description "$note"; fi
    elif [[ $# -eq 2 ]]; then
        note="$2"
        if [[ -z "$note" ]]; then tmux set-option -t "$1" -u @description
        else tmux set-option -t "$1" @description "$note"; fi
    else
        echo 'usage: tdesc "note"  |  tdesc <session> "note"  (empty note clears)' >&2
        return 2
    fi
}

# List tmux sessions with their @description (falls back to the active pane's
# current command when no description is set). `*` marks attached sessions.
tls() {
    tmux list-sessions -F '#{session_name}	#{?session_attached,*, }	#{@description}	#{pane_current_command}' 2>/dev/null \
    | while IFS=$'\t' read -r name att desc cmd; do
        [[ -z "$desc" ]] && desc="($cmd)"
        printf '%-24s %s %s\n' "$name" "$att" "$desc"
    done
}
