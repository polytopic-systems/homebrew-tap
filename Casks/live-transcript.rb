cask "live-transcript" do
  version "1.4.1"
  sha256 "9c103b1b8afc6ee352c89316edd54ec808a71861491c8ef415b5ecb0a544b9d9"

  url "https://livetranscript.polytopic.systems/downloads/Live-Transcript-#{version}.dmg"
  name "Live Transcript"
  desc "On-device live captions, transcripts and translation for any audio"
  homepage "https://livetranscript.polytopic.systems/"

  livecheck do
    url "https://livetranscript.polytopic.systems/appcast.xml"
    strategy :sparkle, &:short_version
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :tahoe

  app "Live Transcript.app"

  uninstall quit: "com.techontires.LiveTranscript"

  zap trash: [
    "~/Library/Application Support/Live Transcript",
    "~/Library/Caches/com.techontires.LiveTranscript",
    "~/Library/HTTPStorages/com.techontires.LiveTranscript",
    "~/Library/HTTPStorages/com.techontires.LiveTranscript.binarycookies",
    "~/Library/Preferences/com.techontires.LiveTranscript.plist",
    "~/Library/WebKit/com.techontires.LiveTranscript",
  ]
end
