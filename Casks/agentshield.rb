cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.716"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.716/agentshield_0.2.716_darwin_amd64.tar.gz"
      sha256 "97242bcfc5a3e8dc16fe3c7516db6bd272236468e6d11b7347fd3b82c6dc2236"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.716/agentshield_0.2.716_darwin_arm64.tar.gz"
      sha256 "6f20c670dc3cd6e742a0002a3ee5b84bafd1e23a37a91298496126d1e9d0fa67"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.716/agentshield_0.2.716_linux_amd64.tar.gz"
      sha256 "e99b51c75de540f1293ba332c49d66ea4af8c47ddc7190b071dd3dfcee0459d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.716/agentshield_0.2.716_linux_arm64.tar.gz"
      sha256 "822b4ee350ff848f6d9666537a12fd9643ba8a906878572c4299448ed2d13d60"
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
