cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2367"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2367/agentshield_0.2.2367_darwin_amd64.tar.gz"
      sha256 "12d8c902296b39a76104c8bebb5893a2969b5aa2c9de6d988269892d6c25a719"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2367/agentshield_0.2.2367_darwin_arm64.tar.gz"
      sha256 "91b717f10378ba602755a18605e4e87d6df25eba5539153fd1fc9424ad71ff50"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2367/agentshield_0.2.2367_linux_amd64.tar.gz"
      sha256 "6df523d08261d72a4518f4aebc0521e6f02bd0d53cf6b9fc27c1fde3b70280e0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2367/agentshield_0.2.2367_linux_arm64.tar.gz"
      sha256 "d96fe128f06ed7b3d9d7301e57910a4dc713499616cafacdd15afb43af203528"
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
