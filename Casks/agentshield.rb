cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1180"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1180/agentshield_0.2.1180_darwin_amd64.tar.gz"
      sha256 "6c5ded5cbdf7664aa6f7305149883420be80144ee4ddd9f2e0b10464a06b02c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1180/agentshield_0.2.1180_darwin_arm64.tar.gz"
      sha256 "398be08e6e44e6773fee46e9f5a75499ca518f14746041537086e0e6a30f2f35"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1180/agentshield_0.2.1180_linux_amd64.tar.gz"
      sha256 "1339ff65233549e68a940bf6987264181f2bb48383c08b551fd4e744b65d8a48"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1180/agentshield_0.2.1180_linux_arm64.tar.gz"
      sha256 "a8767b22b4331709c52d23c70528f3a0aef8a9181932a9d6d9cf8d27266cf60b"
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
