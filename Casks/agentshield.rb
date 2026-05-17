cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1008"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1008/agentshield_0.2.1008_darwin_amd64.tar.gz"
      sha256 "f876ee1087d31ed6953e7c319f3dbd0be7086106416ec0e5da46503cf817b48c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1008/agentshield_0.2.1008_darwin_arm64.tar.gz"
      sha256 "5f9841af0e179da3c756cfc6536af5aa8d6706ae5ea4759f772c19dd3635669f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1008/agentshield_0.2.1008_linux_amd64.tar.gz"
      sha256 "09205eae16cb291876844d64a2b82c16617c2b75187929b7211613c7076ebaf8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1008/agentshield_0.2.1008_linux_arm64.tar.gz"
      sha256 "925d1227a0e3a5875cff560aa1a86c0a8be9cb8ee457783528cdac04904490c5"
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
