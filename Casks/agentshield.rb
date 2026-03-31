cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.259"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.259/agentshield_0.2.259_darwin_amd64.tar.gz"
      sha256 "53c047410979d31180add4a7ec35686956bd737dfbced3bc6a7e485af19b2eb1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.259/agentshield_0.2.259_darwin_arm64.tar.gz"
      sha256 "be5e2eaa7dc7b20c469545927431acdf95a2025fc4a37bb5cf99c5ad71440baf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.259/agentshield_0.2.259_linux_amd64.tar.gz"
      sha256 "402278e769aa118058651d178decd847bd4fa94262a5970ce1501ab489edabdb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.259/agentshield_0.2.259_linux_arm64.tar.gz"
      sha256 "bf30f8f5cb74c19641f85133685a6bc77bb3fadfb8e23ece27e7956fb284dc3f"
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
