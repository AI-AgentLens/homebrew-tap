cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1873"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1873/agentshield_0.2.1873_darwin_amd64.tar.gz"
      sha256 "466586c982fe5d6735ef763871c812b0315ab9f38fa22519023da7bd2e41e7c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1873/agentshield_0.2.1873_darwin_arm64.tar.gz"
      sha256 "92781c495d8e5ca097590ffa250266b117c76b2735840fb277672129d8eaf2ae"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1873/agentshield_0.2.1873_linux_amd64.tar.gz"
      sha256 "9983ff3231d9f9cb0c01742853de9f69e5a03190eef25dea673748d3e74f46c9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1873/agentshield_0.2.1873_linux_arm64.tar.gz"
      sha256 "b42519eb36ebbf0f0bf09caa24076989eb1b55d29349b998523c1a63b75b4f29"
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
