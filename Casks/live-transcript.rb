cask "live-transcript" do
  version "1.3.0"
  sha256 "4d52beb194a85300b1d58666b6c1b6f955ab532d4539c585fa62432bf1c24987"

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
