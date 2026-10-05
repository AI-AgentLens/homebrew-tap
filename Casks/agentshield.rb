cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2350"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2350/agentshield_0.2.2350_darwin_amd64.tar.gz"
      sha256 "8fca564cda5a7e0358d830a78ccd1ba0c373476f464e393d772f7820e7a32034"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2350/agentshield_0.2.2350_darwin_arm64.tar.gz"
      sha256 "c71630f494b383bb84594a2056b29fda44aad42c8c3bb8ab7beda9bd987e6050"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2350/agentshield_0.2.2350_linux_amd64.tar.gz"
      sha256 "d179c8ea28d08fc84e381f52605df7bf088b318a00afa2d06ac77bc0de976fec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2350/agentshield_0.2.2350_linux_arm64.tar.gz"
      sha256 "d22cf6a177b4062459d1e34234ebc58b1d4044a66befd0a6fcd53cf4fe1ae7ff"
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
