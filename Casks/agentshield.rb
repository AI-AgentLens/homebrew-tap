cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.702"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.702/agentshield_0.2.702_darwin_amd64.tar.gz"
      sha256 "d7184d5b604d3b6b5af493c7a1a81bb6027e2e68bccd29dc27d16f3a3969b066"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.702/agentshield_0.2.702_darwin_arm64.tar.gz"
      sha256 "26081b156c66445ab982d1c1cd072797cc7d09448ceb886d980681d4a4370680"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.702/agentshield_0.2.702_linux_amd64.tar.gz"
      sha256 "9edca8af31ef503c0aaa3a13a82ee7312f73ffba8f21f26caaddedd1ca2e6fe3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.702/agentshield_0.2.702_linux_arm64.tar.gz"
      sha256 "fad2a1c4d1f04d9eb45bb263c05be97311219ee35187d2e64f97604349f82db8"
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
