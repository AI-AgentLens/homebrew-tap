cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1892"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1892/agentshield_0.2.1892_darwin_amd64.tar.gz"
      sha256 "24f6c20f5935b7b536096ded7dbf2e98eca8667ac4415d457044a5d41528b61d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1892/agentshield_0.2.1892_darwin_arm64.tar.gz"
      sha256 "dcc94c0817e1ca3a2dee5fc1a0c4479b9fcc8d964e56dc19d2f2dae24e80b540"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1892/agentshield_0.2.1892_linux_amd64.tar.gz"
      sha256 "d78903b07afc633cde9b50f24f4b4711d4819bafc8d56c245b6ecee830a6b314"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1892/agentshield_0.2.1892_linux_arm64.tar.gz"
      sha256 "7d604624bdfd2c76585e4e04adbcab137b88b03852f67f6660c3cb055f4d56c1"
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
