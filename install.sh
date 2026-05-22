#!/usr/bin/env bash
#
# BrightDeck MCP installer
# https://brightdeck.ai
#
# Auto-configures the BrightDeck MCP server in Claude Code (when present)
# and prints copy-paste setup steps for Claude Desktop and ChatGPT.
#
# Non-destructive: never edits config files directly, never runs sudo.
#
# Usage:
#     curl -fsSL https://api.brightdeck.ai/mcp/install.sh | bash
#   or
#     ./install.sh

set -euo pipefail

MCP_URL="https://api.brightdeck.ai/mcp"
MCP_NAME="brightdeck"
SIGNUP_URL="https://brightdeck.ai"

bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
dim()    { printf '\033[2m%s\033[0m\n' "$*"; }
warn()   { printf '\033[33m%s\033[0m\n' "$*"; }
ok()     { printf '\033[32m%s\033[0m\n' "$*"; }
err()    { printf '\033[31m%s\033[0m\n' "$*" >&2; }
rule()   { printf '%s\n' '----------------------------------------------------------------'; }

# Read a y/N answer when running interactively. Defaults to "n" in pipes.
confirm() {
    local prompt="$1"
    local reply=""
    if [ -t 0 ]; then
        read -r -p "$prompt [y/N] " reply </dev/tty || reply=""
    fi
    case "${reply:-n}" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

bold "BrightDeck MCP installer"
dim  "Server: $MCP_URL"
echo
rule
warn "Before you start: BrightDeck MCP needs a free brightdeck.ai account."
warn "If you haven't already, sign up at: $SIGNUP_URL"
rule
echo

# ---- Claude Code (CLI) --------------------------------------------------------

bold "1. Claude Code"
if command -v claude >/dev/null 2>&1; then
    if claude mcp list 2>/dev/null | grep -q "^${MCP_NAME}\b"; then
        ok "  Already registered as '${MCP_NAME}'."
    elif confirm "  Register BrightDeck with Claude Code now?"; then
        if claude mcp add --transport http "$MCP_NAME" "$MCP_URL"; then
            ok "  Added. Run any BrightDeck tool to trigger the OAuth sign-in."
        else
            err "  'claude mcp add' failed. Try running it manually:"
            err "      claude mcp add --transport http $MCP_NAME $MCP_URL"
        fi
    else
        dim "  Skipped. Run it later with:"
        dim "      claude mcp add --transport http $MCP_NAME $MCP_URL"
    fi
else
    dim "  Claude Code CLI not detected on this machine."
    dim "  Install it from https://claude.com/code, then run:"
    dim "      claude mcp add --transport http $MCP_NAME $MCP_URL"
fi
echo

# ---- Claude Desktop -----------------------------------------------------------

bold "2. Claude Desktop"
cat <<EOF
  Open Claude Desktop and:
    1. Go to Settings -> Connectors
    2. Click "Add custom connector"
    3. Name:  BrightDeck
       URL:   $MCP_URL
    4. Click Connect and complete the OAuth sign-in in your browser
    5. In a chat, toggle BrightDeck on from the "+" menu
EOF
echo

# ---- ChatGPT ------------------------------------------------------------------

bold "3. ChatGPT"
cat <<EOF
  Requires ChatGPT Pro, Plus, Business, or Enterprise.

    1. Settings -> Advanced -> turn on Developer mode
    2. Settings -> Connectors -> "Add custom connector"
    3. Name:  BrightDeck
       URL:   $MCP_URL
    4. Complete the OAuth sign-in
    5. In a new chat: + -> More -> Developer mode -> toggle BrightDeck on
EOF
echo

rule
ok "Done. Try this in your client:"
echo "    \"Create a 5-slide deck explaining what BrightDeck does, then export to PowerPoint.\""
rule
