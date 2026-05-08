cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.918"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.918/agentshield_0.2.918_darwin_amd64.tar.gz"
      sha256 "e284f6f54bec7498385d74e34dca941940cdd3f15b3730ef0ddbf9ff5a3c7b30"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.918/agentshield_0.2.918_darwin_arm64.tar.gz"
      sha256 "9ff0e24eee028593420157bde6e8804c5d1188e485856d96b62af91faac72894"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.918/agentshield_0.2.918_linux_amd64.tar.gz"
      sha256 "1556bbe942a376e33d9f0349c0ae4844f9b4ef2cfbc2929e8baef8ab30adeecc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.918/agentshield_0.2.918_linux_arm64.tar.gz"
      sha256 "d30ec14c37ddb65c86d493f4f9f633999ae83fa8e2674e848631f55491e1e3d2"
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
