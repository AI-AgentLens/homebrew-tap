cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1330"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1330/agentshield_0.2.1330_darwin_amd64.tar.gz"
      sha256 "cea92b4b4342572774e8d64773ee4aa680e7e02dcf6f7309e41bfd8c30990ccf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1330/agentshield_0.2.1330_darwin_arm64.tar.gz"
      sha256 "79d0b457e3b45e207c49b88f7ee20d84f1a08320e3aa42d4523e6b6dd453d830"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1330/agentshield_0.2.1330_linux_amd64.tar.gz"
      sha256 "87a82d97e1275fe1c2843db75ba68e914b51e4c7b595b129414c0d899e2c6198"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1330/agentshield_0.2.1330_linux_arm64.tar.gz"
      sha256 "8fc3cd8895680c09ffe0ab7080847a0db90b19ab0fd7eca399f05f932f460023"
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
