cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.695"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.695/agentshield_0.2.695_darwin_amd64.tar.gz"
      sha256 "0120ce36c3e910f24cceb834c4fd017e6c91a98ad88992651a0011860c0f8e35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.695/agentshield_0.2.695_darwin_arm64.tar.gz"
      sha256 "4743dbc8d09ade65916478ae6d8c12e7f59ed95be8ddaf7500f111b91694cc4d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.695/agentshield_0.2.695_linux_amd64.tar.gz"
      sha256 "608295e1b11464b86a24e51c210f2e74e9a0aac8d7d4bf3f04acaf3ab7946256"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.695/agentshield_0.2.695_linux_arm64.tar.gz"
      sha256 "80ff4177e231d3cb03776e5665757beafdba71912fc742546f29352989926a01"
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
