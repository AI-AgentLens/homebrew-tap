cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1364"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1364/agentshield_0.2.1364_darwin_amd64.tar.gz"
      sha256 "6308f8cf4af1807fef85af46a1625c30543a4172b622fc272ae7a6afb154d311"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1364/agentshield_0.2.1364_darwin_arm64.tar.gz"
      sha256 "18763e509253d5ae5de4e9f647e40e9cd40cd001f5c29c3e1f0094a1a171d773"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1364/agentshield_0.2.1364_linux_amd64.tar.gz"
      sha256 "ff26bf00ca3c317267659d9e04bf40851143df60ba0b63fc5ae199cafac0f270"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1364/agentshield_0.2.1364_linux_arm64.tar.gz"
      sha256 "3816968a495abe9e48b1fad37c87419c6dc5e17835059cb1468375b6fa6432e7"
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
