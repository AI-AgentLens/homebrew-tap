cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.365"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.365/agentshield_0.2.365_darwin_amd64.tar.gz"
      sha256 "3380a8be4f540be2dbe73e1f4e91966a3f99ac8901ddac51f9e845ddef740733"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.365/agentshield_0.2.365_darwin_arm64.tar.gz"
      sha256 "542173e3ecd2009b6ebb60b3eff1532df1e1a6d20dfa04e7126e16e3371e9f98"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.365/agentshield_0.2.365_linux_amd64.tar.gz"
      sha256 "d7301c439cf8d0a2803a8fe794ced3235c298aa900755dcb776dada34c46dce1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.365/agentshield_0.2.365_linux_arm64.tar.gz"
      sha256 "326440441e30dca016fe81e869d5527d7ae7882fa2fce0ba15f6a7c49087764a"
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
