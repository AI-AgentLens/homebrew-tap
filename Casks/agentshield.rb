cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1642"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1642/agentshield_0.2.1642_darwin_amd64.tar.gz"
      sha256 "42705f89f7765d4ef3e504300d3c5a6ffe5c219e7471871f354aabb5dc88c6a9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1642/agentshield_0.2.1642_darwin_arm64.tar.gz"
      sha256 "acc4c554ded9c46c451b007f98d2a63a1f474d662b18983d192c3ad0414bea28"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1642/agentshield_0.2.1642_linux_amd64.tar.gz"
      sha256 "ea9f7f6bc52ea3c00ed493883251b373a9e1c3e203dc79a23f0da2475868f053"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1642/agentshield_0.2.1642_linux_arm64.tar.gz"
      sha256 "d0890e0c0a31fb9806baf884d4939a6e8498217b46cf16d2cb23fb0b24d1e8a3"
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
