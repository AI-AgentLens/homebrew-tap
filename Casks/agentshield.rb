cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2395"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2395/agentshield_0.2.2395_darwin_amd64.tar.gz"
      sha256 "e1c80d8de8bef9debf27f55d57cb872c4d4c2b26e3bfea7f1f20b8b5fde7f482"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2395/agentshield_0.2.2395_darwin_arm64.tar.gz"
      sha256 "f7d9e9828c656c4ac690ca4d695df3d0a7dd3d8be7c259d4721c355cf045591b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2395/agentshield_0.2.2395_linux_amd64.tar.gz"
      sha256 "8556e06f0efbdceb5e12165737054000bbda1b8994cb34c64215292e89e1cd4f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2395/agentshield_0.2.2395_linux_arm64.tar.gz"
      sha256 "fca0e9eb891c002983be9e758a36984bbe514ab89a63f7d432dee89d46a3af05"
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
