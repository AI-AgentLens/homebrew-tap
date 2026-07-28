cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1748"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1748/agentshield_0.2.1748_darwin_amd64.tar.gz"
      sha256 "f45fd55a7866d9f7688ecd2959678415ca1b6f2c17d6094c3dea9f5751d0f51e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1748/agentshield_0.2.1748_darwin_arm64.tar.gz"
      sha256 "9a8e7346336e43c035d20f7b13c652feec08c49e76e51c18e2df11696cf2a0b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1748/agentshield_0.2.1748_linux_amd64.tar.gz"
      sha256 "b6191d57fb6e8aebbaa15ec1e0147c3a9821fd7e8f47985a048bdc8683a84267"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1748/agentshield_0.2.1748_linux_arm64.tar.gz"
      sha256 "3337d9d6a00e9c12a99e9f6cfb3fab034c38e2a8e1672900d7baeef6b540868a"
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
