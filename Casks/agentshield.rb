cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2247"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2247/agentshield_0.2.2247_darwin_amd64.tar.gz"
      sha256 "a4db0af7a8724fa4dba528a32033d7ad1456ecfca8a758fdd1ce6bd7fb77e14c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2247/agentshield_0.2.2247_darwin_arm64.tar.gz"
      sha256 "d39c4f496ee033896c7d1fc9ebf20d3918d8b875eff6a0d0d79ae7d817d1fd3d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2247/agentshield_0.2.2247_linux_amd64.tar.gz"
      sha256 "16ace4013c40c6b3a4b63e4f39bd2f9d82414cc42d3f8021f9b4a421c1b4cedc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2247/agentshield_0.2.2247_linux_arm64.tar.gz"
      sha256 "ec095a8502434a60ce0eb141a89bc661f01db2d8de56ed997d50d677319a8d75"
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
