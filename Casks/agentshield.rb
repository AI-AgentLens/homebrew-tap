cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2164"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2164/agentshield_0.2.2164_darwin_amd64.tar.gz"
      sha256 "34abe7edf62f0a3eb94351f468d684264a96900cfd9ec131b543c41d564cd246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2164/agentshield_0.2.2164_darwin_arm64.tar.gz"
      sha256 "7bee7ba185f2cdf7beac3088dbed33a2257f6bf22efb0e45ce850175a01c3d60"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2164/agentshield_0.2.2164_linux_amd64.tar.gz"
      sha256 "d7d6efcab96361a9ad2d4d2ff63511418da67d497b80fe4a48893060ca013433"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2164/agentshield_0.2.2164_linux_arm64.tar.gz"
      sha256 "cf6d15aff51acdb8182e0db5be906994085c11e610ba51145006034824db9757"
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
