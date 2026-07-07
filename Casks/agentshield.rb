cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1573"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1573/agentshield_0.2.1573_darwin_amd64.tar.gz"
      sha256 "edaa73f71cc56ff44943031441f0c8b54e4a8687171234c5d930bfe4c7a195ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1573/agentshield_0.2.1573_darwin_arm64.tar.gz"
      sha256 "8438953dd4e017609e67b1b0e62a1c890060a369779e4f54182842f6549bff2d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1573/agentshield_0.2.1573_linux_amd64.tar.gz"
      sha256 "b184bbc4d3e3401eddaf8c4d9139f0ff5d379cb27ac1cee27069823fcfd41dc2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1573/agentshield_0.2.1573_linux_arm64.tar.gz"
      sha256 "7d0625bc9a857a1c8b131ca2767b69e231bd52a677bd9dbea00ee646cef98ebe"
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
