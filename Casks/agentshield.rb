cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.731"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.731/agentshield_0.2.731_darwin_amd64.tar.gz"
      sha256 "fa649ee7427c6171f2f1c07bd04b7cf52110dd0ccca72526fd603f3b230732fa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.731/agentshield_0.2.731_darwin_arm64.tar.gz"
      sha256 "5f8b3d073fa28fbc59d8967434613bd59b0808811be0e085feeae48a76123b52"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.731/agentshield_0.2.731_linux_amd64.tar.gz"
      sha256 "1e88e383d1066597b02647c253e74e931f0a399c027a22994919c78682f90663"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.731/agentshield_0.2.731_linux_arm64.tar.gz"
      sha256 "83d7c2d9068c41fa5ca982f032ddedc3a41db41ca422c40ad74af64bf68a61f0"
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
