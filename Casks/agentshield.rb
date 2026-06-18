cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1353"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1353/agentshield_0.2.1353_darwin_amd64.tar.gz"
      sha256 "507c5a6d2c489f3e67da3eb178a8cfe199a4b30d04182d9f12595e72fd871c09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1353/agentshield_0.2.1353_darwin_arm64.tar.gz"
      sha256 "8628603cdf53a9e6bc002684923f242379f1ed76a03eed841e59681a24efadad"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1353/agentshield_0.2.1353_linux_amd64.tar.gz"
      sha256 "37d3418d635459ccdfaed7b2281f7bc1277905921929dba02b497bd4caaec3be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1353/agentshield_0.2.1353_linux_arm64.tar.gz"
      sha256 "57121a2ddad2296457826fefdac9c3fa235a864cd70d9b1d7d097198cc9a5e0c"
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
