cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.255"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.255/agentshield_0.2.255_darwin_amd64.tar.gz"
      sha256 "c11895eb1a59b4ce49127483c40b012fac2f9c7e294002a4132450a635777f26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.255/agentshield_0.2.255_darwin_arm64.tar.gz"
      sha256 "3d5218b60e30f9c7415e31e4b554e8a31819ace0f0dd694fffb570e3eb303ac8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.255/agentshield_0.2.255_linux_amd64.tar.gz"
      sha256 "fd6c20b77f0867d11b15ca328499fbfedfad9678b749968064d4bad862e88b40"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.255/agentshield_0.2.255_linux_arm64.tar.gz"
      sha256 "767ee2952f54c5fbf14d2aff38f57bf9a077f7e40e3ebf7e67f1e49ce5cad33f"
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
