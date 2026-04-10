cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.536"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.536/agentshield_0.2.536_darwin_amd64.tar.gz"
      sha256 "8b2298e40a68f9ca8184974e4758174d15cc4026c37f9e6cb2274bc477c0b129"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.536/agentshield_0.2.536_darwin_arm64.tar.gz"
      sha256 "dc9329b5a42ae3c64aa6342c879e653ea45706597531c573088762231053008c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.536/agentshield_0.2.536_linux_amd64.tar.gz"
      sha256 "7daf456ad93c19c734e598e49db93b1cf61e0bf90d78ae40b460b54534aa519c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.536/agentshield_0.2.536_linux_arm64.tar.gz"
      sha256 "a4fd237491870761ce9ea3f9a7e5f89e727187de9f3f3e7cdebfd8cbf2cb8751"
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
