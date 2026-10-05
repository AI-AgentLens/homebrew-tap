cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2351"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2351/agentshield_0.2.2351_darwin_amd64.tar.gz"
      sha256 "3ce1fa94c1443f15b068df36ede13ce36f660c0e3b99fe500bf9135569d996a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2351/agentshield_0.2.2351_darwin_arm64.tar.gz"
      sha256 "0a2b9803b254ac14b7e369132534f9d993f16c2ed0f357786d20154f39dd31ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2351/agentshield_0.2.2351_linux_amd64.tar.gz"
      sha256 "71867f53c472b96e0befa325cfc98df4ed26fcdf390153c9f7e8e476938bae81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2351/agentshield_0.2.2351_linux_arm64.tar.gz"
      sha256 "2fd6471c64d4a35d8f5108057e916433ec742c4c8a6886d2d8a4a0df97d4f590"
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
