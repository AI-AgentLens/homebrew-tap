cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.321"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.321/agentshield_0.2.321_darwin_amd64.tar.gz"
      sha256 "01934c8c59605b233df1418e56626799038f5813c916c7661c64aa15d2ad9a94"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.321/agentshield_0.2.321_darwin_arm64.tar.gz"
      sha256 "1c72455ce4c231352f56276644ca2b2d61fae15c4195f286939a47c1649f857b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.321/agentshield_0.2.321_linux_amd64.tar.gz"
      sha256 "c6acd9d6a8878f882b52e17ef30d5d08b62384ac60924fb7408d8fe1c21e0a74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.321/agentshield_0.2.321_linux_arm64.tar.gz"
      sha256 "795b92864ab7c14ff4f1ccae45085858c84c0d0f61caff4619e9523dd4809e7f"
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
