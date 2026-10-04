cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2337"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2337/agentshield_0.2.2337_darwin_amd64.tar.gz"
      sha256 "6711bb82cb06ab2b15f89c196706806c150061ed1938cd92770ddc1011c346fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2337/agentshield_0.2.2337_darwin_arm64.tar.gz"
      sha256 "a6705b49e104e8e3eabd9338bc4a89fa2deb7bbea2af9f89743e8e51ed014744"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2337/agentshield_0.2.2337_linux_amd64.tar.gz"
      sha256 "c6605231237a8eecf98f66195a8c28d9950b967109283a90cf5d206e5f4d782a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2337/agentshield_0.2.2337_linux_arm64.tar.gz"
      sha256 "1c753f84002f2f492c182d38003c7ebc33372e609e423461ee3f91d883a446ae"
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
