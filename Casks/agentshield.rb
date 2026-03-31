cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.257"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.257/agentshield_0.2.257_darwin_amd64.tar.gz"
      sha256 "79f5a51113f4718bc66d47a74c4a3b2e479bf783d1e86efdaedfd1938743f8e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.257/agentshield_0.2.257_darwin_arm64.tar.gz"
      sha256 "3dd674d5d98cee42fb73fa1493a09b0fe6521debe486221836dcc2e1c0efcb8e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.257/agentshield_0.2.257_linux_amd64.tar.gz"
      sha256 "357c9e4be1f0aa4b337857c9634c6dcc080e402c8654579da496f56c3da16bfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.257/agentshield_0.2.257_linux_arm64.tar.gz"
      sha256 "57a298b704f9e39b1dd9a1c943a5c521924845a81dab228d4cd8d60a9ea16307"
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
