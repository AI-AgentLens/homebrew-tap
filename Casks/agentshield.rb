cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1677"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1677/agentshield_0.2.1677_darwin_amd64.tar.gz"
      sha256 "2662de2494890ae001371d6d1fb0125a32891d4b3389384ce9f4794939f90a65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1677/agentshield_0.2.1677_darwin_arm64.tar.gz"
      sha256 "403510dd5bafad97d9bbf31df23c43a74b044c387be1a0c239f28ad37bf571d5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1677/agentshield_0.2.1677_linux_amd64.tar.gz"
      sha256 "06dc501251effbfdb61e12dea5dbdb4e683232ca58b6302f38f9137608a1dc3c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1677/agentshield_0.2.1677_linux_arm64.tar.gz"
      sha256 "b8f1ed2fc22d93c7564d857b832fc6d02825bbe008affe39976d93c58d768c16"
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
