cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.302"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.302/agentshield_0.2.302_darwin_amd64.tar.gz"
      sha256 "0805951e64d6284fae69b363a0add12026869758c73b6ff609d3a31fb21a7982"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.302/agentshield_0.2.302_darwin_arm64.tar.gz"
      sha256 "225567974452bddeea1716ad2881020c3fd8e461304597f0a6fb11f31208c294"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.302/agentshield_0.2.302_linux_amd64.tar.gz"
      sha256 "7dc6e26eabd139e72a5783ce67df0d233ab10785f341abe8c3482d1225e9c384"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.302/agentshield_0.2.302_linux_arm64.tar.gz"
      sha256 "c14824b82657e5161c7821258a97aeff27b80bc82082ac94a999e1ae05bea7a1"
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
