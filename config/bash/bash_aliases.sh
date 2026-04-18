# Claude Code bash aliases — mirrors zsh wrapper in config/zsh/zshrc.sh
#
# `claude` launches Happy (happy.engineering), which wraps Claude Code.
# Defaults: --model opus[1m] (Opus 4.7, 1M context), --effort max.
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
        happy claude --model 'opus[1m]' --effort max "$@"
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
    tmux new-session -s "${base}-${n}" "happy claude --model 'opus[1m]' --effort max${quoted_args}"
}

# List running claude tmux sessions.
claude-ls() { tmux ls 2>/dev/null | grep -E '^cc-' || echo "no running claude sessions"; }

# Variants that bypass Happy and invoke the raw Claude Code CLI directly.
alias claude_remote='unset ANTHROPIC_API_KEY && command claude'
alias claude_api='ANTHROPIC_API_KEY=$(cat ~/.claude/.api-key) command claude'
