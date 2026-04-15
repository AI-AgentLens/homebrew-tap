cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.601"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.601/agentshield_0.2.601_darwin_amd64.tar.gz"
      sha256 "167d29be591c60e5ce6374d0175fa4763ce2c150a033ee577dc84901a6d686fc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.601/agentshield_0.2.601_darwin_arm64.tar.gz"
      sha256 "55966573ef8e441a663f49e0b29212a6e1fc855f4bcd8ca51e7c70a6999fc0fd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.601/agentshield_0.2.601_linux_amd64.tar.gz"
      sha256 "13c960a029884fc95b1f33622d20b043a00bc9701e5bd96ad99e87b574d67b3a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.601/agentshield_0.2.601_linux_arm64.tar.gz"
      sha256 "d33b897835149872b6f6b7bfc37fb7a31732f1a206c24ee583c6b3df92341f81"
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
