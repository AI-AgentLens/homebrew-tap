cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1514"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1514/agentshield_0.2.1514_darwin_amd64.tar.gz"
      sha256 "2e97f0bb59f7865a32808ceda431df827954e19a4e7812b7b40882cad308d01d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1514/agentshield_0.2.1514_darwin_arm64.tar.gz"
      sha256 "412990eb99eb51620ca6f1eb77ed8ad7a55dd94d97d37c13ad9c6a9e58566776"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1514/agentshield_0.2.1514_linux_amd64.tar.gz"
      sha256 "781aa7f5a78d9d6f0a85cdbf767e37d2c3da9f6dd2a17184b872c880985dfb3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1514/agentshield_0.2.1514_linux_arm64.tar.gz"
      sha256 "ec29c46d21b45cc00898e463eff28cd8104f9a14a3f87aa198ee159162e5b96e"
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
