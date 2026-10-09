# Polytopic Systems Homebrew tap

The [Homebrew](https://brew.sh) tap for Polytopic Systems apps. It holds these casks:

| Cask | App | Requires |
| --- | --- | --- |
| `live-transcript` | [Live Transcript](https://livetranscript.polytopic.systems/): live captions, searchable history and translation, all on your Mac | Apple silicon, macOS 26 or later |
| `tattle` | [Tattle](https://tattle.polytopic.systems/): Your Mac talks behind your back. Tattle tells you. | Apple silicon, macOS 26 or later |

Install any of them with its full name, `brew install --cask polytopic-systems/tap/<cask>`. Each app has its own
section below: install, update, uninstall, and what `--zap` deletes.

## Tap trust (Homebrew 6 and later)

Since Homebrew 6, Homebrew only loads code from third-party taps you have trusted. Installing with the
full name (for example `polytopic-systems/tap/tattle`) trusts that one cask and nothing else in the tap.
You don't need to run anything else.

If you prefer the short name, trust the cask first:

```sh
brew tap polytopic-systems/tap
brew trust --cask polytopic-systems/tap/tattle
brew install --cask tattle
```

`brew trust` lists what you trust; `brew untrust --cask polytopic-systems/tap/<cask>` takes one back.
Uninstalling a cask also drops its trust entry; installing again with the full name trusts it again.
See Homebrew's [Tap Trust](https://docs.brew.sh/Tap-Trust) page for details.

## Live Transcript

[Live Transcript](https://livetranscript.polytopic.systems/): live captions, searchable history and translation,
all on your Mac.

### Install

```sh
brew install --cask polytopic-systems/tap/live-transcript
```

That one command adds the tap and installs the app into `/Applications`. The download is the same notarized
disk image offered on the website, checked against the SHA-256 in the cask.

Already installed from the website? Let Homebrew take over the copy you already have instead of downloading
a second one:

```sh
brew install --cask --adopt polytopic-systems/tap/live-transcript
```

Homebrew records the existing app as installed by this cask; it doesn't download or replace it. Because
the app updates itself, Homebrew adopts it whichever version it is.

### Update

Live Transcript updates itself (Check for Updates… in the app), so the cask is marked `auto_updates` and
a plain `brew upgrade` leaves it alone. To have Homebrew install the newest version of the cask anyway:

```sh
brew upgrade --cask --greedy live-transcript
```

### Uninstall

```sh
brew uninstall --cask live-transcript
```

This quits the app if it is running and removes `Live Transcript.app`. Your history, recordings,
downloaded speech models, settings and license stay on your Mac, so reinstalling picks up where you left
off.

### Removing everything (`--zap`)

```sh
brew uninstall --cask --zap live-transcript
```

**This deletes your Live Transcript history.** On top of uninstalling, it moves these to the Trash:

- `~/Library/Application Support/Live Transcript`: your history and search index, recordings, downloaded
  Whisper models, and the app's license and trial state
- `~/Library/Preferences/com.techontires.LiveTranscript.plist`: your settings
- `~/Library/Caches/com.techontires.LiveTranscript`, `~/Library/HTTPStorages/com.techontires.LiveTranscript`
  (and its `.binarycookies` file) and `~/Library/WebKit/com.techontires.LiveTranscript`: caches, including
  the updater's

It does not remove anything from your Keychain: your license key and any AI provider keys you saved
(Anthropic, OpenRouter, a custom server) stay there. Export anything you want to keep from History first.
If you want the Mac's license seat back, unregister it in the app (or on the
[account page](https://livetranscript.polytopic.systems/account)) before you zap.

## Tattle

[Tattle](https://tattle.polytopic.systems/): Your Mac talks behind your back. Tattle tells you.

### Install

```sh
brew install --cask polytopic-systems/tap/tattle
```

That one command adds the tap, trusts this one cask, and installs the app into `/Applications`. The download is
the same notarized disk image offered on the website, checked against the SHA-256 in the cask.

Already installed from the website? Let Homebrew take over that copy instead of downloading a second one:

```sh
brew install --cask --adopt polytopic-systems/tap/tattle
```

Tattle filters network traffic with a macOS system extension. Keep the app in `/Applications` (macOS only
activates system extensions from there). The first time you open it, macOS asks you to allow the extension;
approve it then, or later in System Settings > General > Login Items & Extensions.

### Update

Tattle updates itself (Check for Updates… in the app), so the cask is marked `auto_updates` and a plain
`brew upgrade` leaves it alone. To have Homebrew install the newest version anyway:

```sh
brew upgrade --cask --greedy tattle
```

Prefer the app's own update: it replaces the system extension in place. A Homebrew upgrade or reinstall first
uninstalls the old copy, which switches the extension off, so macOS asks you to allow it again afterwards.

### Uninstall

```sh
brew uninstall --cask tattle
```

Before the app is removed, Homebrew runs the app's own switch that turns its system extension off (macOS may
ask for an administrator's approval). This matters: deleting the app any other way than through Finder's Trash
leaves an active extension behind with no app to manage it. Then Homebrew quits the app and removes
`Tattle.app`. If you already moved the app to the Trash yourself (Finder takes the extension out in that
case), finish with `brew uninstall --cask --force tattle`.

Your rules, history, settings and license stay on your Mac, so reinstalling picks up where you left off.
If you used Tattle's simple DNS mode and installed its DNS profile, remove that profile yourself in
System Settings > General > Device Management: neither uninstall nor zap touches it.

### Removing everything (`--zap`)

```sh
brew uninstall --cask --zap tattle
```

**This deletes your Tattle rules and history.** On top of uninstalling, it moves these to the Trash:

- `~/Library/Application Support/Tattle`: your rules and firewall settings (network profiles included), the
  connection history and DNS log, DNS settings and downloaded blocklists, the assistant's saved summaries and
  usage counts, and the app's license and trial state
- `~/Library/Preferences/com.techontires.Tattle.plist`: your settings
- `~/Library/Caches/com.techontires.Tattle` and `~/Library/HTTPStorages/com.techontires.Tattle` (and its
  `.binarycookies` file): caches, including the updater's

It does not remove anything from your Keychain: your license key and any AI provider keys you saved
(Anthropic, OpenRouter, a custom server) stay there. To keep your rules, export them first
(Settings > Firewall > Export…). If you want this Mac's license seat back, unregister it in the app (or on
the [account page](https://tattle.polytopic.systems/account)) before you zap.

## For maintainers

### How a release bumps a cask

Each app's release command updates its cask (`Casks/live-transcript.rb`, `Casks/tattle.rb`) after the new
DMG and appcast are live. It replaces exactly two lines and nothing else:

```ruby
version "1.0.3"
sha256 "<sha256 of the 1.0.3 DMG>"
```

The URL is built from `version`, so it needs no edit. Keep exactly one `version "…"` line and exactly one
`sha256 "…"` line in each cask (no `on_arm`/`on_intel` blocks with their own versions): the release
commands depend on it. After replacing them a release command runs, from this repository:

```sh
brew style polytopic-systems/tap
brew audit --cask --strict --online polytopic-systems/tap/<cask>
```

then commits (`<cask> 1.0.3`) and pushes to `main`.

To bump by hand, the same steps:

```sh
shasum -a 256 Tattle-1.0.3.dmg   # or Live-Transcript-1.0.3.dmg; download it from the site first
# edit the version and sha256 lines
brew style polytopic-systems/tap
brew audit --cask --strict --online polytopic-systems/tap/<cask>
brew livecheck --cask polytopic-systems/tap/<cask>   # should show 1.0.3 ==> 1.0.3
git commit -m "<cask> 1.0.3" -- Casks/<cask>.rb && git push
```

### What the casks declare, and why

- `livecheck` reads `sparkle:shortVersionString` from each app's appcast
  (`https://livetranscript.polytopic.systems/appcast.xml`, `https://tattle.polytopic.systems/appcast.xml`),
  so it compares `1.0.3`-style versions, not build numbers.
- `auto_updates true`: the apps update themselves with Sparkle.
- `depends_on arch: :arm64` and `depends_on macos: :tahoe`: `brew audit --online` checks the macOS
  minimum against the app's `LSMinimumSystemVersion` and the feed's `minimumSystemVersion`, and fails
  if they disagree. If a release raises the minimum, change this line in the same commit.
- `uninstall quit:` and `zap trash:` use each app's bundle id: `com.techontires.LiveTranscript` for
  `live-transcript`, `com.techontires.Tattle` for `tattle`. If an app starts writing somewhere new under
  `~/Library`, add it to its `zap` (and to its section above).
- `tattle` also has `uninstall early_script:`: before the app is removed it runs
  `Tattle.app/Contents/MacOS/Tattle --deactivate-extension`, which turns the app's network system extension
  off (removing an app with `rm`, as Homebrew does, would leave an active extension behind). It exits 0 at
  once when no extension is installed, as on a CI runner; `must_succeed: false` so a refused approval prompt
  doesn't leave a half-uninstalled cask. The cask's comments have the details.

### CI

`.github/workflows/ci.yml` runs on every push and pull request on a `macos-26` (Apple silicon) runner, once
per cask (a matrix): `brew style`, `brew audit --cask --strict --online`, then a real install, a Gatekeeper
and signature check of the installed app, and an uninstall. Every Monday it runs `brew livecheck` for each
cask and fails if an appcast has a newer version than its cask, which means a release went out without its
bump. A new cask gets an entry in both matrices.

### Testing a change locally

Tap the checkout under a throwaway name, with Homebrew's trust list in a temporary folder, so your own
Homebrew setup (and a `polytopic-systems/tap` you may already have tapped) stays as it is:

```sh
export HOMEBREW_NO_AUTO_UPDATE=1 XDG_CONFIG_HOME="$(mktemp -d)"
brew tap hx-check/tap "/path/to/this/checkout"     # clones the committed state
brew trust --tap hx-check/tap
brew style hx-check/tap
brew audit --cask --strict --online hx-check/tap/<cask>
brew livecheck --cask hx-check/tap/<cask>
brew untap hx-check/tap
```

To try an install without touching a copy you already have in `/Applications`, quit the app first
(uninstall quits it by bundle id), then install into a separate folder:

```sh
mkdir -p ~/Applications/brew-test
brew install --cask --appdir ~/Applications/brew-test hx-check/tap/live-transcript
spctl --assess --type execute --verbose=4 ~/Applications/brew-test/"Live Transcript.app"
brew uninstall --cask hx-check/tap/live-transcript
```

Don't do this for `tattle` on a Mac where Tattle is in use: its uninstall runs `--deactivate-extension`,
which switches off the extension of the copy in `/Applications` too (it is the same extension). Leave the
`tattle` install to CI, or use a Mac without Tattle.
