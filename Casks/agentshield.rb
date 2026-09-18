cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2175"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2175/agentshield_0.2.2175_darwin_amd64.tar.gz"
      sha256 "8323ebf3803a3bd512675de9dbabe03f527943065fe80f461e58bcc751b975d8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2175/agentshield_0.2.2175_darwin_arm64.tar.gz"
      sha256 "2599bf56d6050f7531815ebe01901bf4842e9e2deb36f664f49ce3c9becb84b8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2175/agentshield_0.2.2175_linux_amd64.tar.gz"
      sha256 "b51b04b1a853354bff01438c78469efe05a5a758e69469ecb7bd580461520cfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2175/agentshield_0.2.2175_linux_arm64.tar.gz"
      sha256 "4e142d7829c6294a66247355d222c2333be9e820b7f32ec2353037d51afe22ce"
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
