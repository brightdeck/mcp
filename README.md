# BrightDeck MCP Server

**Create polished, PowerPoint-ready presentations from any LLM client.**

BrightDeck is a hosted [Model Context Protocol](https://modelcontextprotocol.io/) server that lets ChatGPT, Claude, and other MCP-compatible clients generate, edit, share, and export professional decks on your behalf. Ask your AI assistant to "draft a 10-slide pitch deck about my Series A," and BrightDeck builds a real, branded, exportable presentation — no manual slide-by-slide work, no template hunting.

Learn more at [brightdeck.ai](https://brightdeck.ai/).

---

> **Before you start:** BrightDeck MCP requires a free brightdeck.ai account.
> [Sign up here](https://brightdeck.ai/) before connecting any client — otherwise the OAuth handshake will fail with *"No deck account is linked to this Firebase identity."*

---

## Quick start

**Server URL:** `https://api.brightdeck.ai/mcp`

Run one command:

```bash
curl -fsSL https://raw.githubusercontent.com/brightdeck/mcp/main/install.sh | bash
```

The script auto-configures [Claude Code](#claude-code) if it's installed, and prints copy-paste setup for [Claude Desktop](#claude-desktop) and [ChatGPT](#chatgpt). It never edits config files for you and never asks for sudo.

Want to inspect it first? Open [install.sh on GitHub](https://github.com/brightdeck/mcp/blob/main/install.sh).

Prefer to configure manually? Pick your client below.

---

## Install

### Claude Code

Run one command:

```bash
claude mcp add --transport http brightdeck https://api.brightdeck.ai/mcp
```

The first time you call a BrightDeck tool, Claude Code opens a browser tab to complete the OAuth handshake. Sign in with the account you used at brightdeck.ai. That's it.

Verify the server is registered:

```bash
claude mcp list
```

### Claude Desktop

1. Open **Settings → Connectors**.
2. Click **Add custom connector**.
3. Enter:
   - **Name:** `BrightDeck`
   - **URL:** `https://api.brightdeck.ai/mcp`
4. Click **Connect**. A browser tab opens for OAuth — sign in with your brightdeck.ai account.
5. Back in Claude Desktop, toggle the connector **on** in the conversation's `+` menu.

> Claude Desktop requires the server to be reachable from Anthropic's IP ranges. BrightDeck's hosted endpoint already is, so no firewall changes are needed.

### ChatGPT

Custom MCP connectors require **ChatGPT Pro, Plus, Business, or Enterprise** with **Developer Mode** enabled.

1. Open **Settings → Advanced → Developer mode**, and turn it on.
2. Go to **Settings → Connectors** and click **Add custom connector**.
3. Enter:
   - **Name:** `BrightDeck`
   - **URL:** `https://api.brightdeck.ai/mcp`
4. Complete the OAuth flow in the popup.
5. In a new chat, click **+ → More → Developer mode** and toggle **BrightDeck** on.

---

## What you can do

BrightDeck exposes 11 tools, grouped by what you actually want to do:

### Generate

| Tool | Use it to... |
|---|---|
| `deck_create_presentation` | Generate a complete, themed deck from a prompt — optionally seeded with reference files (PDF, PPTX, DOCX, images). Returns a live preview link immediately while generation continues in the background. |
| `deck_create_blank_presentation` | Create an empty deck to edit from scratch. Useful when you want to build slide-by-slide. |

### Manage

| Tool | Use it to... |
|---|---|
| `deck_list_presentations` | Browse the decks you own or have access to, newest first. |
| `deck_get_presentation` | Look up one deck's details (filename, slide count, visibility, your role). |
| `deck_update_presentation` | Rename a deck, change visibility (private / public view / public comment / public edit), or toggle page numbers. |

### Share

| Tool | Use it to... |
|---|---|
| `deck_get_share_link` | Get the canonical view URL for a deck and its current visibility. |
| `deck_share_presentation` | Invite someone by email as owner / admin / editor / commenter / viewer. Sends an invitation if they don't have an account yet. |
| `deck_list_permissions` | See who has access to a deck and their role. |
| `deck_revoke_permission` | Remove someone's access. |

### Export

| Tool | Use it to... |
|---|---|
| `deck_export_pptx_url` | Get a 60-minute signed download URL for the deck as a real `.pptx` file — editable in PowerPoint, Keynote, or Google Slides. |
| `deck_export_pdf_url` | Same, but as PDF. |

---

## Example prompts

Try these in any connected client:

- *"Create a 10-slide investor pitch for a B2B SaaS company that sells AI-powered legal contract review. Make it look modern and confident."*
- *"Draft a deck explaining our Q3 roadmap, then export it to PowerPoint so I can send it to the team."*
- *"List my last five presentations and share the most recent one with alice@example.com as an editor."*
- *"I have this PDF [attached] — turn it into a 6-slide summary deck and email me the share link."*

---

## Authentication

BrightDeck uses **OAuth 2.1 with PKCE** ([RFC 7636](https://datatracker.ietf.org/doc/html/rfc7636)) and **Dynamic Client Registration** ([RFC 7591](https://datatracker.ietf.org/doc/html/rfc7591)). Discovery endpoints are published per the [MCP authorization specification](https://modelcontextprotocol.io/specification/draft/basic/authorization):

- `https://api.brightdeck.ai/.well-known/oauth-authorization-server`
- `https://api.brightdeck.ai/.well-known/oauth-protected-resource`
- `https://api.brightdeck.ai/.well-known/jwks.json`

Claude Code, Claude Desktop, and ChatGPT handle the OAuth handshake automatically — you only see a browser sign-in. Tokens are short-lived JWTs (ES256) and refresh transparently.

Tools require one of these scopes, which your client requests automatically:

| Scope | Grants |
|---|---|
| `presentation:read` | List / view decks, get share links, list permissions, get export URLs |
| `presentation:write` | Create / rename / share / revoke / update visibility |
| `agent:run` | Run AI generation (`deck_create_presentation`) |

---

## Troubleshooting

**"No deck account is linked to this Firebase identity."**
You signed in with a Google/email account that hasn't been registered at brightdeck.ai. Visit [brightdeck.ai](https://brightdeck.ai/), sign up with the same email, then retry the connection.

**ChatGPT doesn't show my connector option.**
Custom connectors require ChatGPT **Pro, Plus, Business, or Enterprise** and **Developer Mode** enabled (Settings → Advanced → Developer mode).

**The OAuth browser tab never returns.**
Pop-ups may be blocked. Allow pop-ups for `api.brightdeck.ai` and your client's domain (e.g. `claude.ai`, `chatgpt.com`), then retry.

**Claude Code says "server already exists" on `claude mcp add`.**
Either you've already added it, or a previous attempt left a stub. Remove and re-add:
```bash
claude mcp remove brightdeck
claude mcp add --transport http brightdeck https://api.brightdeck.ai/mcp
```

**A tool returned `[presentation.not_found]` or `[permission.denied]`.**
The tool ran successfully, but the underlying API rejected the request. Check that the presentation ID is one you have access to. Use `deck_list_presentations` to see what's available.

---

## Learn more

- **Product:** [brightdeck.ai](https://brightdeck.ai/)
- **MCP specification:** [modelcontextprotocol.io](https://modelcontextprotocol.io/)
- **Support:** Open an issue in this repository, or email the team via the contact form at [brightdeck.ai](https://brightdeck.ai/).

---

## License

This README and the accompanying `install.sh` are released under the same license as the parent repository. The BrightDeck MCP server itself is operated by BrightDeck — see the [brightdeck.ai](https://brightdeck.ai/) terms of service for usage limits and acceptable use.
