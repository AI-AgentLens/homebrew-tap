cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1044"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1044/agentshield_0.2.1044_darwin_amd64.tar.gz"
      sha256 "ba9ef426cc67fcb47211a31bcbe4f5389c2ed785ee4fab8115f52b7d1e89ef71"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1044/agentshield_0.2.1044_darwin_arm64.tar.gz"
      sha256 "b095ba5a183f20d719dea5d9e92b70f69ae153b6a85ba1326079da02f87012e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1044/agentshield_0.2.1044_linux_amd64.tar.gz"
      sha256 "737a3553782d8afc989287862f7c860d74f45fc7dd9b31d0b862a252b7f4b0ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1044/agentshield_0.2.1044_linux_arm64.tar.gz"
      sha256 "80e7c34855f3910d0676908fc51d9fc19d0ecc7d40598a529f150558ff24bb5a"
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
