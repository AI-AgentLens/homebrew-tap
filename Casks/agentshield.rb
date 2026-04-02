cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.339"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.339/agentshield_0.2.339_darwin_amd64.tar.gz"
      sha256 "1dd54591103287902da6c8f837b6de7cf587a1210f36d39856d7725771e51415"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.339/agentshield_0.2.339_darwin_arm64.tar.gz"
      sha256 "33c70b8e1e25dad3de6f70625b353762e1aadbf367832927b114d876c754d3ee"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.339/agentshield_0.2.339_linux_amd64.tar.gz"
      sha256 "fb2efb9e6e1051e7f671b4516e2952f6200032229bb8f2d8a94e6f730763360d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.339/agentshield_0.2.339_linux_arm64.tar.gz"
      sha256 "2f1928978ce716f6af5bc3f17b9dabda49f606251d5f41e70bf0a140cba9969b"
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
