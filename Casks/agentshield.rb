cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.480"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.480/agentshield_0.2.480_darwin_amd64.tar.gz"
      sha256 "f9b1be74f1ed12773df84e7a29886236f7f66b2e96c48e4e4cd2b194a3b75dec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.480/agentshield_0.2.480_darwin_arm64.tar.gz"
      sha256 "c084d61271fcd9120b69cf8cafa7aaaef4a902a0f96b1d0b44c1f6fdca84372d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.480/agentshield_0.2.480_linux_amd64.tar.gz"
      sha256 "fb96018ac372f075a0c1b17320774093c2c39c46803952800e10c9cc9e58cd2f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.480/agentshield_0.2.480_linux_arm64.tar.gz"
      sha256 "bcaa8bcaad1df823befb10e980a3e4847d6db0d1e469d189f3fb13b0c127dc0e"
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
