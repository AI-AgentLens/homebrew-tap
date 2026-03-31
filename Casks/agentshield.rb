cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.261"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.261/agentshield_0.2.261_darwin_amd64.tar.gz"
      sha256 "834077fc88854dc2dd8e0bf9ed068530a3bfb90a35e0ad07748ffa14ab31e58a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.261/agentshield_0.2.261_darwin_arm64.tar.gz"
      sha256 "012e1a34daa90d7538a1ecee11af789e3d75f852e11873a82f877742bd494ef2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.261/agentshield_0.2.261_linux_amd64.tar.gz"
      sha256 "d94c4052e2e4ac008b59711c14aee31fb9109a39a39337da44b063bb9d7f27ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.261/agentshield_0.2.261_linux_arm64.tar.gz"
      sha256 "4a324a89f866f4e5830f9de38d541d3e7394a5e8f3b4cee8e7b3052b8449ec69"
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
