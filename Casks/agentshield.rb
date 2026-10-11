cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2403"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2403/agentshield_0.2.2403_darwin_amd64.tar.gz"
      sha256 "e6c53cb0b38debd5c70e21556e2644a431ddd1f3581ae63599702ffeec03c019"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2403/agentshield_0.2.2403_darwin_arm64.tar.gz"
      sha256 "ef93e78e41fe8589357ac12bd74aea017278bdf0b0aca329a1ac608723d3ba14"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2403/agentshield_0.2.2403_linux_amd64.tar.gz"
      sha256 "9f111654612b4abfe34589cd0acb8f72cdcd16ff30d6d4d8fc01fb398ef05847"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2403/agentshield_0.2.2403_linux_arm64.tar.gz"
      sha256 "655cd97a009b17ab21d75a008eed64023e067107ecbad1087ac666ede63d4d27"
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
