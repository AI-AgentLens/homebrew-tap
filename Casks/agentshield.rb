cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1950"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1950/agentshield_0.2.1950_darwin_amd64.tar.gz"
      sha256 "8e928a870b0ee9ee10028b405c903d04469cf10b4685d6537e91b4e55a2d0e61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1950/agentshield_0.2.1950_darwin_arm64.tar.gz"
      sha256 "d35c2835be3acace53f73946ec515026cd7f9c7940d641c3c86ce9fc6a4d40ef"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1950/agentshield_0.2.1950_linux_amd64.tar.gz"
      sha256 "ad76ab950ead3fcf4f1adad7e9014553b10f9a818baf758000757847ea891678"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1950/agentshield_0.2.1950_linux_arm64.tar.gz"
      sha256 "db233eaba1f5aef9d0bfe061c4f885be258b0a71d5baf1eb630906f61a4de0ad"
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
