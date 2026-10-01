cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2307"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2307/agentshield_0.2.2307_darwin_amd64.tar.gz"
      sha256 "f20c6d066fcdd998073e2608e5db4ad82146891f51d38b1bd132b2848b2a71d2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2307/agentshield_0.2.2307_darwin_arm64.tar.gz"
      sha256 "d8ad5cb9d1a588f9959b0695c3058e91cf5d50b301b154c47e6a7bb4969f5621"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2307/agentshield_0.2.2307_linux_amd64.tar.gz"
      sha256 "c8fcae28e8777b0c3f662fa7038b039be60385f5a90b85a5ab840cbf9b5b0480"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2307/agentshield_0.2.2307_linux_arm64.tar.gz"
      sha256 "2a5535e49e47954df84de5932927028d8eb8d8ea95a3f32ac63d026660892d0c"
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
