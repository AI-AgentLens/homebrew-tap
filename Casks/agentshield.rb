cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1592"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1592/agentshield_0.2.1592_darwin_amd64.tar.gz"
      sha256 "a753a4623683fe77591dfd558dcb97a44e5fb8b913ffa44c03e9bd14dae650ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1592/agentshield_0.2.1592_darwin_arm64.tar.gz"
      sha256 "d3778f989b54b8814890be992db75b562e754f58009196057ed4f37314f333f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1592/agentshield_0.2.1592_linux_amd64.tar.gz"
      sha256 "fa646be6b10b2b5ad44a5c29b50b7e67507fd2c456305d57656bec788c61fd05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1592/agentshield_0.2.1592_linux_arm64.tar.gz"
      sha256 "432d46ec18a6677fd8f95a56d726cab8098b2ab1f85008ab1a81257bfc311e0d"
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
