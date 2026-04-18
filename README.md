# MacDoctor — Website

Landing page and installer for [mac-doctor](https://github.com/androidshashi/macdoctor), a CLI tool that finds and cleans developer storage bloat on macOS.

**Live site:** https://macdoctor.site

---

## Project structure

```
macdoctor-web/
├── public/
│   ├── index.html      # Landing page (plain HTML, no framework)
│   └── install.sh      # Installer script served at /install.sh
└── vercel.json         # outputDirectory + headers config
```

## Deploy

This project is deployed on [Vercel](https://vercel.com). No build step required — it's all static files.

```bash
vercel --prod
```

Vercel automatically serves everything in `public/` at the root, so `public/install.sh` is available at `https://macdoctor.site/install.sh`.

---

## install.sh

The installer is served at `/install.sh` and is invoked via:

```bash
curl -sSL https://macdoctor.site/install.sh | bash
```

**What it does:**

1. Checks that the system is macOS (`Darwin`) and the architecture is `arm64` or `x86_64`
2. Asks for confirmation before doing anything (reads from `/dev/tty` so it works correctly in a `curl | bash` pipe)
3. Downloads the binary from GitHub
4. Validates the downloaded file is non-empty and looks like an executable (Mach-O or shell script)
5. Makes it executable and moves it to `/usr/local/bin/mac-doctor` (uses `sudo` only if needed)
6. Cleans up the temp file on exit via `trap`, even on failure

**It never deletes anything.**

---

## mac-doctor CLI — what it does

> Version: **1.1.0**

Interactive storage analyzer and safe cleaner for macOS developers. Scans and optionally removes:

| Category | What gets cleaned |
|---|---|
| **VS Code** | Renderer cache, compiled extension code, downloaded VSIX packages, GPU shader cache, blob cache, logs, crash reports, workspace storage, local file history, installed extensions |
| **Xcode** | DerivedData (build cache), app archives |
| **iOS Simulators** | Unavailable simulator runtimes (`xcrun simctl delete unavailable`), simulator app data (`xcrun simctl erase all`) |
| **Android** | SDK download cache, AVD emulator directories |

**Safety model:**
- Every deletion is confirmed interactively before proceeding
- Paths are resolved to absolute form and validated against a safe-root whitelist (`~/Library/`, `~/.android/`, `~/.vscode/`)
- Directory names are checked against an explicit whitelist of known-safe leaf names
- Non-interactive mode (piped stdin) skips all deletions automatically

### Usage

```bash
mac-doctor               # Interactive menu
mac-doctor --dry-run     # Preview what would be deleted, delete nothing
mac-doctor --version     # Print version
mac-doctor --help        # Print usage
```

---

## Local development

No dependencies. Open `index.html` directly in a browser, or use any static server:

```bash
npx serve .
# or
python3 -m http.server 3000
```

To test the installer locally:

```bash
bash public/install.sh
```

---

## Security notes

- `install.sh` is served with `Content-Type: text/plain` and `Cache-Control: no-store` to ensure `curl` always fetches the latest version
- The binary is currently pulled from the `main` branch of the GitHub repo — for production hardening, consider pinning to a tagged release URL and verifying a SHA256 checksum in the installer
- No analytics, no tracking, no telemetry on the website or in the CLI

## License

MIT
