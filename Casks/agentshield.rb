cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1484"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1484/agentshield_0.2.1484_darwin_amd64.tar.gz"
      sha256 "fa9f5e951a3dfdaa2e0f9db262016908ae64fc944543b1890747b5bda0107e31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1484/agentshield_0.2.1484_darwin_arm64.tar.gz"
      sha256 "9da6c884388bc80e09914aa33d6b376f0509f5e8f4bd619b8d76def0518ce97c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1484/agentshield_0.2.1484_linux_amd64.tar.gz"
      sha256 "9d318ca886bb4a499d6814eb407f085bab172320231ab23130afa51c1d565e5e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1484/agentshield_0.2.1484_linux_arm64.tar.gz"
      sha256 "80d93123d97b3cccaf847ef2d8591861b7f176eaa19db90c6c494e2a91897b39"
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
