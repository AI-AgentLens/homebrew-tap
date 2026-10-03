cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2328"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2328/agentshield_0.2.2328_darwin_amd64.tar.gz"
      sha256 "d5f14e1ba6905c67e715e4945e3dd0f0f2490106e07ea52714f83e0289110740"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2328/agentshield_0.2.2328_darwin_arm64.tar.gz"
      sha256 "569b72d42520d48487d6c276cac4bebe8ced595026240c03f7f195aad056d4a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2328/agentshield_0.2.2328_linux_amd64.tar.gz"
      sha256 "2f5a2577ca890243fa0f72d9f7338026c2f35b028c94761b3c10431296877d55"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2328/agentshield_0.2.2328_linux_arm64.tar.gz"
      sha256 "11018210bb6684073c5285d412e62d431051fdf6997d664aa31980ed5f91fd0e"
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
