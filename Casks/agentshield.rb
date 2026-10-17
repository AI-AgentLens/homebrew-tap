cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2450"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2450/agentshield_0.2.2450_darwin_amd64.tar.gz"
      sha256 "cfbdf32065ea0a8aaeadbf082ac9c0a9d3e64b39c3122c79a520bdb4bbf0573f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2450/agentshield_0.2.2450_darwin_arm64.tar.gz"
      sha256 "d47d811338b5a8e73f498eb87e1673858d6a71ebd3dc19d9265ef2b8b2e9c861"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2450/agentshield_0.2.2450_linux_amd64.tar.gz"
      sha256 "dc36fb6aaca74f5428382a22bb14368b776d5a43da948d8518f1a5b433cdae05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2450/agentshield_0.2.2450_linux_arm64.tar.gz"
      sha256 "79afae1d8f311b69b9a43fd0090dad69a5bdd843c6bb1829d119010caf469b5f"
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
