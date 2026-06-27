cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1461"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1461/agentshield_0.2.1461_darwin_amd64.tar.gz"
      sha256 "7cb62bbeefbe4d1d3847b852f8226567087177dbccee1b91f12305de569f2f03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1461/agentshield_0.2.1461_darwin_arm64.tar.gz"
      sha256 "7012f5931ff164470a4cb2385213bbcca196e093c864ad309f9688d7f4d8627d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1461/agentshield_0.2.1461_linux_amd64.tar.gz"
      sha256 "e151b6b1a90eaa628507a8432646e780e117c94cba8654d72af780b1525fa052"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1461/agentshield_0.2.1461_linux_arm64.tar.gz"
      sha256 "ce356eb3c0004ceef1de456a976f6cf5cbcea18d10fba214d22f425c43cacbee"
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
