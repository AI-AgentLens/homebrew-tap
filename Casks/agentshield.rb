cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1670"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1670/agentshield_0.2.1670_darwin_amd64.tar.gz"
      sha256 "ad3f5a44a9ecdc070397a956de1aa79422d10cb40cd400b4f96cab5a80639294"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1670/agentshield_0.2.1670_darwin_arm64.tar.gz"
      sha256 "31ed176b56af3ed515a576a376fc4673ba31a644a8855c65ac2836398eace4eb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1670/agentshield_0.2.1670_linux_amd64.tar.gz"
      sha256 "13db3b2040403dc8b732bfbf060537ff5b7652a75fadef19d1942a6a287ecb48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1670/agentshield_0.2.1670_linux_arm64.tar.gz"
      sha256 "89d60213fef7aa1bb16c36afd00f317e5ac4f3a4e401c9fbfc1af85aa9d2c6bb"
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
