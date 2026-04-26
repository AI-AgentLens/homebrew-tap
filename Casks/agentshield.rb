cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.746"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.746/agentshield_0.2.746_darwin_amd64.tar.gz"
      sha256 "e06bf26b78e5633b5cfb375a8e6840e061d23af63f4c16790d66c9a18a07f204"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.746/agentshield_0.2.746_darwin_arm64.tar.gz"
      sha256 "c2f311245ec8d13d7d3c4032e75a997e19abcddaff579445711420aa0762f611"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.746/agentshield_0.2.746_linux_amd64.tar.gz"
      sha256 "d08b71e4649ac8c83496767ce2db21a60f5a849cdfeda5ee43f2f9ad540b069d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.746/agentshield_0.2.746_linux_arm64.tar.gz"
      sha256 "6085ca0348c7d74a5e8f2572bf3fbb51cfafc8d6789fb2473c875dd824a7a27a"
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
