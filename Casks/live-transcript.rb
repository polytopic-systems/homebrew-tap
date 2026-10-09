cask "live-transcript" do
  version "1.2.0"
  sha256 "c3bbcee4c2a5ee5f45face14eb6d863368d03e1935fc6f8d46f70bcef3467cfb"

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
