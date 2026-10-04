# Polytopic Systems Homebrew tap

The [Homebrew](https://brew.sh) tap for Polytopic Systems apps. It holds one cask today:

| Cask | App | Requires |
| --- | --- | --- |
| `live-transcript` | [Live Transcript](https://livetranscript.polytopic.systems/): live captions, searchable history and translation, all on your Mac | Apple silicon, macOS 26 or later |

## Install

```sh
brew install --cask polytopic-systems/tap/live-transcript
```

That one command adds the tap and installs the app into `/Applications`. The download is the same notarized
disk image offered on the website, checked against the SHA-256 in the cask.

### Tap trust (Homebrew 6 and later)

Since Homebrew 6, Homebrew only loads code from third-party taps you have trusted. Installing with the
full name, as above, trusts this one cask (`polytopic-systems/tap/live-transcript`) and nothing else in
the tap. You don't need to run anything else.

If you prefer the short name, trust the cask first:

```sh
brew tap polytopic-systems/tap
brew trust --cask polytopic-systems/tap/live-transcript
brew install --cask live-transcript
```

`brew trust` lists what you trust; `brew untrust --cask polytopic-systems/tap/live-transcript` takes it back.
See Homebrew's [Tap Trust](https://docs.brew.sh/Tap-Trust) page for details.

### Already installed from the website?

Let Homebrew take over the copy you already have instead of downloading a second one:

```sh
brew install --cask --adopt polytopic-systems/tap/live-transcript
```

Homebrew records the existing app as installed by this cask; it doesn't download or replace it. Because
the app updates itself, Homebrew adopts it whichever version it is.

## Update

Live Transcript updates itself (Check for Updates… in the app), so the cask is marked `auto_updates` and
a plain `brew upgrade` leaves it alone. To have Homebrew install the newest version of the cask anyway:

```sh
brew upgrade --cask --greedy live-transcript
```

## Uninstall

```sh
brew uninstall --cask live-transcript
```

This quits the app if it is running and removes `Live Transcript.app`. Your history, recordings,
downloaded speech models, settings and license stay on your Mac, so reinstalling picks up where you left
off. Homebrew also drops its trust entry for the cask; installing again with the full name trusts it again.

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

## For maintainers

### How a release bumps the cask

The release command updates `Casks/live-transcript.rb` after the new DMG and appcast are live. It
replaces exactly two lines and nothing else:

```ruby
version "1.0.3"
sha256 "<sha256 of Live-Transcript-1.0.3.dmg>"
```

The URL is built from `version`, so it needs no edit. Keep exactly one `version "…"` line and exactly one
`sha256 "…"` line in the file (no `on_arm`/`on_intel` blocks with their own versions): the release
command depends on it. After replacing them it runs, from this repository:

```sh
brew style polytopic-systems/tap
brew audit --cask --strict --online polytopic-systems/tap/live-transcript
```

then commits (`live-transcript 1.0.3`) and pushes to `main`.

To bump by hand, the same steps:

```sh
shasum -a 256 Live-Transcript-1.0.3.dmg   # or download it from the site first
# edit the version and sha256 lines
brew style polytopic-systems/tap
brew audit --cask --strict --online polytopic-systems/tap/live-transcript
brew livecheck --cask polytopic-systems/tap/live-transcript   # should show 1.0.3 ==> 1.0.3
git commit -am "live-transcript 1.0.3" && git push
```

### What the cask declares, and why

- `livecheck` reads `sparkle:shortVersionString` from the appcast
  (`https://livetranscript.polytopic.systems/appcast.xml`), so it compares `1.0.3`-style versions,
  not build numbers.
- `auto_updates true`: the app updates itself with Sparkle.
- `depends_on arch: :arm64` and `depends_on macos: :tahoe`: `brew audit --online` checks the macOS
  minimum against the app's `LSMinimumSystemVersion` and the feed's `minimumSystemVersion`, and fails
  if they disagree. If a release raises the minimum, change this line in the same commit.
- `uninstall quit:` and `zap trash:` use the bundle id `com.techontires.LiveTranscript`. If the app starts
  writing somewhere new under `~/Library`, add it to `zap`.

### CI

`.github/workflows/ci.yml` runs on every push and pull request on a `macos-26` (Apple silicon) runner:
`brew style`, `brew audit --cask --strict --online`, then a real install, a Gatekeeper and signature
check of the installed app, and an uninstall. Every Monday it runs `brew livecheck` and fails if the
appcast has a newer version than the cask, which means a release went out without its bump.

### Testing a change locally

```sh
brew tap polytopic-systems/tap "/path/to/this/checkout"     # clones the committed state
brew style polytopic-systems/tap
brew audit --cask --strict --online polytopic-systems/tap/live-transcript
brew livecheck --cask polytopic-systems/tap/live-transcript
brew untap polytopic-systems/tap
```

To try an install without touching a copy you already have in `/Applications`, quit Live Transcript
first (uninstall quits it by bundle id), then install into a separate folder:

```sh
mkdir -p ~/Applications/brew-test
brew install --cask --appdir ~/Applications/brew-test polytopic-systems/tap/live-transcript
spctl --assess --type execute --verbose=4 ~/Applications/brew-test/"Live Transcript.app"
brew uninstall --cask live-transcript
```
