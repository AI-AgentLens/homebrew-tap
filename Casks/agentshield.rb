cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1234"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1234/agentshield_0.2.1234_darwin_amd64.tar.gz"
      sha256 "9e1bde960ea661b0f4a880bb86dd89f265f2f38b3288704385776ce38a487f5c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1234/agentshield_0.2.1234_darwin_arm64.tar.gz"
      sha256 "ad5265888096627e304b541aa53ad21f91e5198fb39589ffdc769f6c7ec53ac1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1234/agentshield_0.2.1234_linux_amd64.tar.gz"
      sha256 "f4d775bb51c42b7d1bc111144806305b1338f9297aa7fa16680a0c5a4e8b1ac3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1234/agentshield_0.2.1234_linux_arm64.tar.gz"
      sha256 "3a80a2d42774e3521ec254d4723616efd92562f63109d6204bca9b491125cb33"
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
