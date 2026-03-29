cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.189"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.189/agentshield_0.2.189_darwin_amd64.tar.gz"
      sha256 "d142e0a639933be6a36f84cb4949f971bdbaa57d61ede210930b0e0c068cde14"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.189/agentshield_0.2.189_darwin_arm64.tar.gz"
      sha256 "580fe9f6de701bf08110d642b6d9c5ec2d3a853cb0b5e394869319ac24f81d61"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.189/agentshield_0.2.189_linux_amd64.tar.gz"
      sha256 "767f825809d4aaad8331fdfaeb557ea47acf0d26c46db91400fa1cf80992a9cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.189/agentshield_0.2.189_linux_arm64.tar.gz"
      sha256 "716a1fca5547d40e60559d1c9219e01a120845fa277ad9449a19316cb7dc8250"
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
