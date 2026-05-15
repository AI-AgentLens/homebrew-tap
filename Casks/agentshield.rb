cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.981"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.981/agentshield_0.2.981_darwin_amd64.tar.gz"
      sha256 "ab85a764172e72d2e557193582122bd02c986b2b0b718e6d770c8d2ebcca3ff4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.981/agentshield_0.2.981_darwin_arm64.tar.gz"
      sha256 "0d3bdee07e06c1569ee099955c1d3177a862137eefa2073dd16a18866641a661"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.981/agentshield_0.2.981_linux_amd64.tar.gz"
      sha256 "cf71e07b36bb053d02912233b1bcc98b0f8e5618b4fa117db206b38558af96f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.981/agentshield_0.2.981_linux_arm64.tar.gz"
      sha256 "82fd5a497807e650eee21430bc2fa1472d8d34a23146f826c4c296d85f3aa5f0"
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
