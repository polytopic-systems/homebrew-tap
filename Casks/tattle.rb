# Homebrew cask for Tattle (https://tattle.polytopic.systems/). Cask reference: https://docs.brew.sh/Cask-Cookbook
#
# The line contract (README, "For maintainers"): exactly one `version "…"` line and exactly one `sha256 "…"` line,
# each indented two spaces, and no on_arm/on_intel blocks with versions of their own. Tattle's release command
# (Tools/ship.sh in the app's repository) replaces those two lines and nothing else; the URL is built from `version`.
cask "tattle" do
  version "1.0.0"
  sha256 "4010ce88efcc45249b31bd386f272f38e2704f3476b9fffd6bc7a3c8ac64ae05"

  url "https://tattle.polytopic.systems/downloads/Tattle-#{version}.dmg"
  name "Tattle"
  desc "Network monitor and firewall that shows which apps connect where"
  homepage "https://tattle.polytopic.systems/"

  # Reads sparkle:shortVersionString from the update feed, so it compares 1.0.3-style versions, not builds.
  livecheck do
    url "https://tattle.polytopic.systems/appcast.xml"
    strategy :sparkle, &:short_version
  end

  # The app updates itself (Check for Updates… in the app), so a plain `brew upgrade` leaves it alone.
  auto_updates true
  # Apple silicon only, like the app's build settings. If the app ever ships as a universal binary, remove this.
  depends_on arch: :arm64
  # `brew audit --online` compares this with the app's LSMinimumSystemVersion (and the feed's
  # minimumSystemVersion): if a release raises the minimum macOS, change this line in the same commit.
  depends_on macos: :tahoe

  app "Tattle.app"

  # The app carries a network filter as a system extension. Deleting the app with `rm` (which is what Homebrew
  # does) does NOT remove an activated system extension: it stays active with its app gone. Only moving the app
  # to the Trash in Finder, or a deactivation request from the app itself, takes it out
  # (https://developer.apple.com/documentation/systemextensions/installing-system-extensions-and-drivers).
  # So, before Homebrew removes the app, it runs the app's own command-line switch. It removes Tattle's filter
  # configuration, asks macOS (without a prompt) whether the extension is installed, and if it is, submits
  # OSSystemExtensionRequest.deactivationRequest and waits for the answer (up to 5 minutes). Exit status: 0 when
  # the extension is gone or was never installed, 1 when the deactivation was refused or failed, 2 on timeout.
  # macOS may ask for an administrator's approval while it runs.
  #
  # early_script is the same pattern the official Santa cask uses for its system extension. It is not one of
  # the structured uninstall_preflight_steps because those run inside Homebrew's sandbox, where a request to the
  # system extension daemon (and its approval prompt) is not something to rely on.
  # must_succeed: false keeps a refused prompt from leaving a half-uninstalled cask; the extension can then be
  # switched off in System Settings > General > Login Items & Extensions, or by reinstalling and choosing
  # Remove Network Extension… in the app.
  #
  # Known edges, also in the tap README section for this cask:
  # - It runs on `brew reinstall` and `brew upgrade --greedy` too (Homebrew runs uninstall before reinstalling),
  #   so the new copy asks for approval again. Updating from inside the app replaces the extension in place.
  # - If the app was already moved to the Trash by hand, Finder took care of the extension and this executable
  #   is gone: `brew uninstall --force tattle` skips the missing script.
  uninstall early_script: {
              executable:   "#{appdir}/Tattle.app/Contents/MacOS/Tattle",
              args:         ["--deactivate-extension"],
              must_succeed: false,
            },
            quit:         "com.techontires.Tattle"

  # zap moves the app's own data to the Trash. Everything the app writes is under Application Support/Tattle
  # (rules and settings, history, DNS settings and blocklists, assistant files, license and trial state); the
  # rest is its preferences and the caches macOS and the updater keep by bundle id. If the app starts writing
  # somewhere new under ~/Library, add it here (and to the tap README's zap list). Keychain items (license key,
  # AI provider keys) are left alone. The network extension runs as root and keeps its own state in its own
  # container, which zap does not reach; the app does not use its app group container.
  zap trash: [
    "~/Library/Application Support/Tattle",
    "~/Library/Caches/com.techontires.Tattle",
    "~/Library/HTTPStorages/com.techontires.Tattle",
    "~/Library/HTTPStorages/com.techontires.Tattle.binarycookies",
    "~/Library/Preferences/com.techontires.Tattle.plist",
  ]

  caveats <<~EOS
    Tattle filters network traffic with a macOS system extension.
    Keep Tattle.app in /Applications: macOS only activates system extensions
    from there, and moving the app elsewhere stops the filter.
    The first time you open it, macOS asks you to allow the extension; approve it
    when asked, or later in System Settings > General > Login Items & Extensions.
  EOS
end
