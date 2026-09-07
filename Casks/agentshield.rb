cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2079"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2079/agentshield_0.2.2079_darwin_amd64.tar.gz"
      sha256 "7b63ee33b5a71a77be88d61deb9511680ef020ed7e2100ad9c5e2030cc3402cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2079/agentshield_0.2.2079_darwin_arm64.tar.gz"
      sha256 "9c757da2c0803b776dcf2d4cb7f276876be4219c53aa1ed5e58e1fe212ec8f82"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2079/agentshield_0.2.2079_linux_amd64.tar.gz"
      sha256 "7b33be5c5b6e416a71636897c4a22aca1a6591fa15e949e69ad5c56b18582aac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2079/agentshield_0.2.2079_linux_arm64.tar.gz"
      sha256 "be57259b52cca1a78a114d1f13ee2e4155697a0ad3e0be5b2cf2e9be25ffd981"
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
