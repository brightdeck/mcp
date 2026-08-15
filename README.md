# BrightDeck Integrations

**Create polished, PowerPoint-ready presentations from ChatGPT, Claude, Zapier, n8n — or any MCP client.**

[BrightDeck](https://brightdeck.ai/) is an AI presentation maker: ask for "a 10-slide pitch deck about my Series A" and get a real, branded, exportable presentation — no manual slide-by-slide work, no template hunting. This repository documents every way to connect it.

| Platform | Fastest path |
|---|---|
| **ChatGPT** | [Install the BrightDeck app](https://chatgpt.com/plugins/plugin_asdk_app_6a090196cf008191b1333063eea54038) — one click, no setup |
| **Claude** | [Install the Brightdeck connector](https://claude.ai/new#settings/customize-connectors/directory/brightdeck-ai) — one click, works in claude.ai, Claude Desktop & Claude Code |
| **Zapier** | [BrightDeck on Zapier](#zapier) — connect 7,000+ apps, no code |
| **n8n** | [Community node or built-in MCP client](#n8n) |
| **Any other MCP client** | Server URL: `https://api.brightdeck.ai/mcp` |

At the core is a hosted [Model Context Protocol](https://modelcontextprotocol.io/) server. The Zapier and n8n integrations speak the same MCP API under the hood — one account, one OAuth sign-in, no API keys anywhere.

---

> **Before you start:** every integration requires a free brightdeck.ai account.
> [Sign up here](https://brightdeck.ai/) before connecting — otherwise the OAuth handshake will fail with *"No deck account is linked to this Firebase identity."*

---

## AI assistants (MCP)

### Claude

**Install the connector (recommended):** open the [Brightdeck connector in the Claude directory](https://claude.ai/new#settings/customize-connectors/directory/brightdeck-ai), click **Connect**, and sign in with your brightdeck.ai account. That covers claude.ai and Claude Desktop — and connectors installed there are also available in Claude Code when you're signed in with the same account.

**Or register the MCP server directly in Claude Code:**

```bash
claude mcp add --transport http brightdeck https://api.brightdeck.ai/mcp
```

The first time you call a BrightDeck tool, Claude Code opens a browser tab to complete the OAuth handshake. Sign in with the account you used at brightdeck.ai. Verify with `claude mcp list`.

### ChatGPT

**Install the app (recommended):** open the [BrightDeck app in ChatGPT](https://chatgpt.com/plugins/plugin_asdk_app_6a090196cf008191b1333063eea54038) and add it. The first time it runs, sign in with your brightdeck.ai account. No Developer Mode required.

**Or add a custom MCP connector** (requires ChatGPT **Pro, Plus, Business, or Enterprise** with Developer Mode):

1. Turn on **Settings → Advanced → Developer mode**.
2. Go to **Settings → Connectors**, click **Add custom connector**, and enter name `BrightDeck`, URL `https://api.brightdeck.ai/mcp`.
3. Complete the OAuth flow, then toggle **BrightDeck** on under **+ → More → Developer mode** in a new chat.

### Other MCP clients

Point any MCP-compatible client at `https://api.brightdeck.ai/mcp` (HTTP transport, OAuth handled automatically). Or run the setup script, which auto-configures Claude Code if installed and prints copy-paste steps for everything else — it never edits config files for you and never asks for sudo:

```bash
curl -fsSL https://raw.githubusercontent.com/brightdeck/mcp/main/install.sh | bash
```

Want to inspect it first? Open [install.sh on GitHub](https://github.com/brightdeck/mcp/blob/main/install.sh).

---

## Automation platforms

### Zapier

The BrightDeck integration on [Zapier](https://zapier.com/apps) connects your account to 7,000+ apps. Add a BrightDeck step in the Zap editor, click **Sign in**, and approve access on the BrightDeck consent page — the connection is labeled with your account email, tokens refresh automatically, and you can revoke it anytime from your BrightDeck account settings.

| Type | Operation | What it does |
|---|---|---|
| Trigger | **New Presentation** | Fires when a presentation is created (polling). Fires on *creation* — pair with **Get Generation Status** if you need the finished deck. |
| Action | **Create AI Presentation** | Generates a deck from a prompt (up to 4,000 characters). Optional: slide count (1–50, plan caps apply), style, content density. Returns immediately with `presentation_id` and a live `view_url` while slides build in the background. |
| Action | **Export PPTX / Export PDF** | Returns a real Zapier **File** (map it into Gmail, Slack, Drive, etc.) plus a signed `download_url`. |
| Action | **Share Presentation** | Shares a deck by email with a role (Viewer → Owner). Non-users get an email invitation that grants the role on signup. |
| Search | **Find Presentation** | Exact lookup by ID, or case-insensitive title search over your 50 most recent decks. Returns nothing (not an error) on no match, so "create if not found" flows work. |
| Search | **Get Generation Status** | Live status of an AI generation run: `status`, `stage`, slides finished vs. planned, failure detail. |

**The generate-then-export pattern** — Create AI Presentation returns in seconds while the deck builds for a few minutes. To act on the *finished* deck: **Create AI Presentation** → **Delay** (3–5 min) → **Get Generation Status** → **Filter** (`status` exactly `completed`) → **Export / Share**.

Things to know:

- **Export links expire in 60 minutes.** For anything downstream, map the **File** field instead of `download_url` — Zapier fetches and stores it at run time.
- **Plan limits surface as Zap errors** with the billing message, rather than silently returning nothing.
- **`filename` is the title.** The API calls a presentation's title `filename`.

### n8n

Two ways to use BrightDeck from n8n:

**Community node — [A.I. Slides by Brightdeck](https://www.npmjs.com/package/@brightdeck/n8n-nodes-ai-slides).** On self-hosted n8n: **Settings → Community Nodes → Install** and enter `@brightdeck/n8n-nodes-ai-slides`. Twelve operations covering create, manage, share, and export, with credentials handled via OAuth sign-in.

**Zero code — built-in MCP Client Tool** (works on n8n Cloud and self-hosted n8n ≥ 2.28.0):

1. Attach an **MCP Client Tool** sub-node to an AI Agent (or use the standalone **MCP Client** node).
2. **Endpoint:** `https://api.brightdeck.ai/mcp/` — **Authentication:** **MCP OAuth2** (leave Resource URL empty).
3. Click **Connect** and sign in. No client ID, secret, or scopes to fill in.

> ⚠️ The MCP Client Tool's per-call **Timeout** defaults to 60 s; `deck_create_presentation` runs 30–120 s. Set **Options → Timeout** to **180000** ms or the call aborts mid-generation.

**Generate → wait → export:** `deck_create_presentation` (returns `presentation_id`, `task_id`, live `view_url`) → poll `deck_get_task_status` until `completed` (a 15–30 s Wait node between polls is plenty) → `deck_export_pptx_url` / `deck_export_pdf_url`.

Skip `mode: "interactive"` and the `deck_answer_questions` / `deck_approve_plan` tools in workflows — they pause server-side for a human answer, which is built for chat agents, not unattended automation.

---

## What you can do

BrightDeck exposes 15 MCP tools, grouped by what you actually want to do:

### Generate

| Tool | Use it to... |
|---|---|
| `deck_create_presentation` | Generate a complete, themed deck from a prompt. Returns a live preview link immediately while generation continues in the background. |
| `deck_create_presentation_v2` | Same, seeded with uploaded reference files (up to five: PDF, PPTX, DOCX, images). |
| `deck_create_blank_presentation` | Create an empty deck to edit from scratch. Useful when you want to build slide-by-slide. |
| `deck_get_task_status` | Check a background generation run: status, stage, slides finished vs. planned. |
| `deck_answer_questions` / `deck_approve_plan` | Power the interactive create flow (clarifying questions, then plan approval). Built for chat clients — skip them in unattended automations. |

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

Every client — ChatGPT, Claude, Zapier, and n8n alike — handles the OAuth handshake automatically against the same authorization server; you only see a browser sign-in. Tokens are short-lived JWTs (ES256) and refresh transparently.

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
Custom connectors require ChatGPT **Pro, Plus, Business, or Enterprise** and **Developer Mode** enabled (Settings → Advanced → Developer mode). Or skip that entirely and [install the BrightDeck app](https://chatgpt.com/plugins/plugin_asdk_app_6a090196cf008191b1333063eea54038) instead.

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
