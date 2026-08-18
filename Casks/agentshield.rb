cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1898"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1898/agentshield_0.2.1898_darwin_amd64.tar.gz"
      sha256 "9ba47404fb08f4ebc542cf821bcccfff6a8106fc8a875ef7743e6cd446c9ba7c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1898/agentshield_0.2.1898_darwin_arm64.tar.gz"
      sha256 "3f4c0cb6a6335871fe57e336650e7625854147492177663c9d0520d353836c13"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1898/agentshield_0.2.1898_linux_amd64.tar.gz"
      sha256 "558ff0dafdd5996be4898bcaa79256b6825fb4beaf3cd14e17909e52f71a22bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1898/agentshield_0.2.1898_linux_arm64.tar.gz"
      sha256 "47fbc74d3d390fe468a69d4a8df86f2554cd6f00f831d20852287358f4a3f768"
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
