cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1877"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1877/agentshield_0.2.1877_darwin_amd64.tar.gz"
      sha256 "d37e81de54204ded727347ccec0038c607fdff4c886a243f5ca264c1c04c84fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1877/agentshield_0.2.1877_darwin_arm64.tar.gz"
      sha256 "88c6344f596551cac32ed08fe275cf68f1776ccc3bcaf1e1927d2f004e248f18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1877/agentshield_0.2.1877_linux_amd64.tar.gz"
      sha256 "7fc7ccc2fff34dc3aaf3d0e18f4975c8ca28d8d967e490a663758638f15620d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1877/agentshield_0.2.1877_linux_arm64.tar.gz"
      sha256 "8592f70c15bc0c0423caac4c47c1ba02a3d4c904fed849ee6d6ab601785947db"
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
