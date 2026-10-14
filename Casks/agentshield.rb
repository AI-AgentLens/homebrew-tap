cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2423"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2423/agentshield_0.2.2423_darwin_amd64.tar.gz"
      sha256 "9b5fb8850472887b921951eadc5c420ef31363db41b9e75c323525bc8a47fcba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2423/agentshield_0.2.2423_darwin_arm64.tar.gz"
      sha256 "8cf623ef072f23487e2f29cee29662efdbcc8c50b74a503176bfa8f96be1716a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2423/agentshield_0.2.2423_linux_amd64.tar.gz"
      sha256 "26dcdda336d81e0058922a7d54163b9aefc697295791cdbbc2c91642ec2706e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2423/agentshield_0.2.2423_linux_arm64.tar.gz"
      sha256 "0b68cbc116d20baefe24a7576379c4b723bf93f314dcff5e4ce43e8f766b074c"
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
