cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2249"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2249/agentshield_0.2.2249_darwin_amd64.tar.gz"
      sha256 "7b8ff079619ec06b1d48380e76d13ae38e89ea9eb8b218e2c35a18dfd2f2d5a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2249/agentshield_0.2.2249_darwin_arm64.tar.gz"
      sha256 "fed23e608f2d2348608bcd59f252b3168945d5f1637561f4087c3bdc996b6d28"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2249/agentshield_0.2.2249_linux_amd64.tar.gz"
      sha256 "70afb4b421e2bd35af257ebe842417591e071c450ce3b9b665f3ad0574771045"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2249/agentshield_0.2.2249_linux_arm64.tar.gz"
      sha256 "7ce424eeb08a8429fc527d8d598f8101851ed5cf07fe5bce7d918b53ade4152a"
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
