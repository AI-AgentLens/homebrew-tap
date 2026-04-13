cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.577"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.577/agentshield_0.2.577_darwin_amd64.tar.gz"
      sha256 "59e932175323e4868aaba2669bb8af0c38af4a8b5d1af1e2fb6fd724c5286d33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.577/agentshield_0.2.577_darwin_arm64.tar.gz"
      sha256 "60e0673e078c2d57828d62a09a513a5839879a75c243c6697225de9efbb8d1e9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.577/agentshield_0.2.577_linux_amd64.tar.gz"
      sha256 "3cd0a6a7f97930044d8fc5febb4f85b5669b1389bb52850c6df871a9bf69efee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.577/agentshield_0.2.577_linux_arm64.tar.gz"
      sha256 "6b84055cbd818385389bde38f28970e31f40876f79ea7c2fcae28772147e2d61"
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
