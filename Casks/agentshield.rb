cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1591"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1591/agentshield_0.2.1591_darwin_amd64.tar.gz"
      sha256 "8d9e20538335a743670da3dcfa168d48bfc83ca5e696b2b5672edc1fdf84560f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1591/agentshield_0.2.1591_darwin_arm64.tar.gz"
      sha256 "3d3f6313a3c03893917d05c4b1d67b10ced56292e6d8883fa70bceae040f4d52"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1591/agentshield_0.2.1591_linux_amd64.tar.gz"
      sha256 "13b2b448c893f22ef32ef14e9f0da40a01f75798102dfd5dbdc35831588440a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1591/agentshield_0.2.1591_linux_arm64.tar.gz"
      sha256 "76b1899b615f2b05f44e02d77b83517e4d7614cf2af873640897ec9dc0e6b947"
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
