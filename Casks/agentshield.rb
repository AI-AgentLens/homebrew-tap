cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1239"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1239/agentshield_0.2.1239_darwin_amd64.tar.gz"
      sha256 "d65faf4a9e06a293dafcbfd768033daa3691fe9a6b8d23a88338e6375eb4e282"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1239/agentshield_0.2.1239_darwin_arm64.tar.gz"
      sha256 "814a6e5caa42d800e091ba44658a5b29c57bc120749716bc8845b1280ed3004c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1239/agentshield_0.2.1239_linux_amd64.tar.gz"
      sha256 "760fde2f3d0231ace0a646ef7e0859d9583d835824511874718c399f6bc4ecdd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1239/agentshield_0.2.1239_linux_arm64.tar.gz"
      sha256 "714027874c152163e83972c47d0b477e6bc374ee1b2d1f0299429ba352c5f0a2"
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
