cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.210"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.210/agentshield_0.2.210_darwin_amd64.tar.gz"
      sha256 "61601dc23b61082f5e53af0a80dc148e2479ca8bc8b62f97d3c22be28beca200"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.210/agentshield_0.2.210_darwin_arm64.tar.gz"
      sha256 "041b60d3fb0259041e38af610a98da8c932d02902eac52b9abff3170b33c8ee7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.210/agentshield_0.2.210_linux_amd64.tar.gz"
      sha256 "e0d3a40a76f00d2ef4fc2d3151e41dbaa4713a3ce8ff95854afc83609eea2152"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.210/agentshield_0.2.210_linux_arm64.tar.gz"
      sha256 "d5ed08c90cafe6b9aa211b8fcf4c98093477831c2f37521c0ab5ec3f63337b0a"
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
