cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.566"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.566/agentshield_0.2.566_darwin_amd64.tar.gz"
      sha256 "51a63f020ac448a1d0d3640396502eaf0a7de46f5d51f8019476186dcc88574d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.566/agentshield_0.2.566_darwin_arm64.tar.gz"
      sha256 "b20870ee3e1996991ebbdfc68bb3f7c1a29ef7535d7daf89fb1fc4a42f15dacd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.566/agentshield_0.2.566_linux_amd64.tar.gz"
      sha256 "a18114018cbe3d778367844f583754850eb3397404b6d31844852c2b19a83088"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.566/agentshield_0.2.566_linux_arm64.tar.gz"
      sha256 "a79838ab23a9b1f9cb3b2248999f7e80d75fd859c00ce3f63ec5a831e3f28bab"
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
