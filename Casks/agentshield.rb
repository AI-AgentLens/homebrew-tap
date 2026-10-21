cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2494"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2494/agentshield_0.2.2494_darwin_amd64.tar.gz"
      sha256 "53e30887b39d1589314d69511f04f5598bc537295bbab03a1e1769195d2ba2cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2494/agentshield_0.2.2494_darwin_arm64.tar.gz"
      sha256 "9e6103bda79fe80cac9478f5f754eaaafec84164878ba937dd9e207437f253b3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2494/agentshield_0.2.2494_linux_amd64.tar.gz"
      sha256 "92b671303fc4568e0b2edb740760822b62e714a474d62c27549d2c7cb1153b9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2494/agentshield_0.2.2494_linux_arm64.tar.gz"
      sha256 "a78a9581788e285a79c67d710142063ed9afe51f1bd03df031b2e1940ef81b4f"
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
