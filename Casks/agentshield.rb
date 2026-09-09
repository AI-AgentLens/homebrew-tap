cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2095"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2095/agentshield_0.2.2095_darwin_amd64.tar.gz"
      sha256 "a107a0db12ae756d4b9158070be2a1e24e59dc4e91d6fc46768fe31cb03b7b74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2095/agentshield_0.2.2095_darwin_arm64.tar.gz"
      sha256 "a597ab2081f3b978ec8a825265c49ee26dfece19bfc4a6f1bf465cd354c21e3b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2095/agentshield_0.2.2095_linux_amd64.tar.gz"
      sha256 "7e70e8658161f3ed4d98ed4f249dcea075b6003ca6c2819442eb372de4e2aa48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2095/agentshield_0.2.2095_linux_arm64.tar.gz"
      sha256 "15a4e39d99bc93e5112e86d176e614599fae1d2b3816712c62989e1d42201018"
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
