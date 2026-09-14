cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2140"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2140/agentshield_0.2.2140_darwin_amd64.tar.gz"
      sha256 "a82411bbfde3f299768b50f664d0070514952eb5ae3a94353b77959ace1ad69c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2140/agentshield_0.2.2140_darwin_arm64.tar.gz"
      sha256 "59073e579778a0bbc54105baa63d2701f8fdf70cc56343f3fe80880e2f14abd2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2140/agentshield_0.2.2140_linux_amd64.tar.gz"
      sha256 "00a483cdfba352933b9e9478a5bf1a422eca29637567db35232d428cc2397dd8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2140/agentshield_0.2.2140_linux_arm64.tar.gz"
      sha256 "86b52de4a67a571c615c8069caa51cc00763f286ef9a8abb9cc78bebcddf2c02"
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
