cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2253"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2253/agentshield_0.2.2253_darwin_amd64.tar.gz"
      sha256 "78076142fab9eee31a881967df62bad5b82e8d974c37e82d8aae3d2ecc981123"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2253/agentshield_0.2.2253_darwin_arm64.tar.gz"
      sha256 "0e202b99360afb92c64a4527ea80df759e50cc94281cdfb696c6532526f55c80"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2253/agentshield_0.2.2253_linux_amd64.tar.gz"
      sha256 "a24c6db934be24ed6f6d30f1f5495332a169653ac8fd885549cac85c74c61efa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2253/agentshield_0.2.2253_linux_arm64.tar.gz"
      sha256 "0f08700acf131094efb8c7c38210d815dc6a3a3fdd43813bb9b96ba79f3e5454"
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
