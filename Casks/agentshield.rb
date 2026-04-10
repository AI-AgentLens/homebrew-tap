cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.518"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.518/agentshield_0.2.518_darwin_amd64.tar.gz"
      sha256 "607fa75f5859b8c130e1dfc6f9f11eb25827b842fb2fb5af8a6b5b9b3171645c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.518/agentshield_0.2.518_darwin_arm64.tar.gz"
      sha256 "f4ba487ddae8039267e8d31694ef9459d307856ce8b7c78ccb8b1d2e3a3d738f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.518/agentshield_0.2.518_linux_amd64.tar.gz"
      sha256 "5c35d813698b865a4cae0bee33ffc95fdf9b33c764940fea4bf3415d72650074"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.518/agentshield_0.2.518_linux_arm64.tar.gz"
      sha256 "60dabe8208ac1fab0b357c7bf560c2debef0d85a385773ba9c72118e5134a6f7"
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
