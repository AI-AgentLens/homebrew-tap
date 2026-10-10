cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2389"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2389/agentshield_0.2.2389_darwin_amd64.tar.gz"
      sha256 "f44bc2ea511b05a2eb9c53c9027b48a36999e510ec270276bdbaf2dcc3017dc9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2389/agentshield_0.2.2389_darwin_arm64.tar.gz"
      sha256 "cdcc3b80a263ce6ae70011487c8cce9c2adeec5284d0fbf74dbb68ef086ecd97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2389/agentshield_0.2.2389_linux_amd64.tar.gz"
      sha256 "710a934ad42db76cc2e95e99b63f1df0bb9fd907fdce69d14430439777fc530c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2389/agentshield_0.2.2389_linux_arm64.tar.gz"
      sha256 "81bdcace48916db12456599a737fc905a4f38c51cba061883f4caf6d6e451537"
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
