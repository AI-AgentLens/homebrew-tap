cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1356"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1356/agentshield_0.2.1356_darwin_amd64.tar.gz"
      sha256 "92093ae8327d1546144d15f4ecb894fe29c380f0e69cf26cfc3e90403394b172"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1356/agentshield_0.2.1356_darwin_arm64.tar.gz"
      sha256 "bc841c3356c8f1013b6b0b2ea218cada82a7494437e5f6edf0e6d86db1f002ef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1356/agentshield_0.2.1356_linux_amd64.tar.gz"
      sha256 "aaf30c61789ba1205d75116b6c9733bcd62c7391a1408ccb68b70156bd5c4d03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1356/agentshield_0.2.1356_linux_arm64.tar.gz"
      sha256 "43c11fdbfbbbd1593dd2ba9dfe7a6d19546960b9789adf12e571e5b02dce9fb2"
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
