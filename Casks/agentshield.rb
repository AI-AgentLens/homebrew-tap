cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1500"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1500/agentshield_0.2.1500_darwin_amd64.tar.gz"
      sha256 "611dd45457210637262b113c36092eda75a134b6189eaf8428cdcd6fe89e3f58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1500/agentshield_0.2.1500_darwin_arm64.tar.gz"
      sha256 "b1ffbcae3c868ba6e594b7a918af00faa976474c6d274ce77122e28ec34ac5ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1500/agentshield_0.2.1500_linux_amd64.tar.gz"
      sha256 "6d8c454ad344b851b55caf186499c523bcbf294c6e7a16a6b19d1e54b0434f35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1500/agentshield_0.2.1500_linux_arm64.tar.gz"
      sha256 "0067de132890033bfe5f9b6e22879d4736e294745a346ac6f3c4f87d0ecfc030"
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
