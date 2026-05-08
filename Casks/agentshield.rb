cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.912"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.912/agentshield_0.2.912_darwin_amd64.tar.gz"
      sha256 "ecb229d21621b4f450624a404e9f33f35aa106b96090c7d6a6e3d9c3a1732b0c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.912/agentshield_0.2.912_darwin_arm64.tar.gz"
      sha256 "785e45be48bfac50e5cca132a215ee6f25ed5acf95634eba54400c656987945a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.912/agentshield_0.2.912_linux_amd64.tar.gz"
      sha256 "9049bcd73f22ebd3a756a8486065a84556097620a706b46b5bee028496b88e83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.912/agentshield_0.2.912_linux_arm64.tar.gz"
      sha256 "0794cf1d9e9a4a502b0d998d38c9f21eaa67dac91bd7cba2ffbddfeb55322550"
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
