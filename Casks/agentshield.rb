cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1742"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1742/agentshield_0.2.1742_darwin_amd64.tar.gz"
      sha256 "081f590f16c7ef17ff2cb8bd01682915d3848ba654c86ed973610626686d8bb9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1742/agentshield_0.2.1742_darwin_arm64.tar.gz"
      sha256 "35a19bb862e4adf6d2ddc1c0334f6f905390eea9965e97bd4efc526dd52b1e6b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1742/agentshield_0.2.1742_linux_amd64.tar.gz"
      sha256 "959df934a4c2b3b190f52e73ef438bbb520b3c6a54acf0a80843ff14c6f6c369"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1742/agentshield_0.2.1742_linux_arm64.tar.gz"
      sha256 "7bcdddb527ca860e1bf5218fc73893a3964d10200a8a0b05c17261510927ea43"
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
