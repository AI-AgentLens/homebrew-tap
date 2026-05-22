cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1078"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1078/agentshield_0.2.1078_darwin_amd64.tar.gz"
      sha256 "a95bef198ecbaa2fa69187ca91c43994893d738ba4c352f7ac51988bd8f84582"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1078/agentshield_0.2.1078_darwin_arm64.tar.gz"
      sha256 "604118a845e8848eedff7f155e9cca6bf66bbfb423a844876798667befd50c0b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1078/agentshield_0.2.1078_linux_amd64.tar.gz"
      sha256 "8938f4c492869cc5f7be3ae441656a2a36bfe8f784f09f5b8df72bd4bbc41cbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1078/agentshield_0.2.1078_linux_arm64.tar.gz"
      sha256 "48729b940b299cb8b020460dd38e83ff03f5d47682b32d39fffc6605a9da5e32"
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
