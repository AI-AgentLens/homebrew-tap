cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1625"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1625/agentshield_0.2.1625_darwin_amd64.tar.gz"
      sha256 "de3fea7e4e8aa94e78bc7042edee834d6374d592c00c1db39e10b1db9d36cee5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1625/agentshield_0.2.1625_darwin_arm64.tar.gz"
      sha256 "a8a6251e7879ef59e716d5f5064471b373aee41500c3a76ec907cd4c50595f26"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1625/agentshield_0.2.1625_linux_amd64.tar.gz"
      sha256 "3fe09b14fe2398bfb10611404028e01370f96faa1abb12bd9ccf66e2c52406a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1625/agentshield_0.2.1625_linux_arm64.tar.gz"
      sha256 "99214d95ab784b0930b4eec4cf7b6a55fd4dd5c5853500359ae77be96dfd0803"
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
