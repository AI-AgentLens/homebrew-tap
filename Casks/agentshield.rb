cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.632"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.632/agentshield_0.2.632_darwin_amd64.tar.gz"
      sha256 "6b20618b23483bee402823f76ca64c9c374bab1767fb09cb4ab60a028b31bc59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.632/agentshield_0.2.632_darwin_arm64.tar.gz"
      sha256 "002b91da88a5159d8c072a32ef0ce74cdbd7ea64a598fa59cd804c97ea2510fc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.632/agentshield_0.2.632_linux_amd64.tar.gz"
      sha256 "25de454d6e81e3d4fad88f1280d2d2e174a2887be565f08b07b2041b5e0d7b91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.632/agentshield_0.2.632_linux_arm64.tar.gz"
      sha256 "11f5e0ed843c1a6a0255f169fb032ae5628a55e7051244714904e6a7ab193a6c"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
