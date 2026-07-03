cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1536"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1536/agentshield_0.2.1536_darwin_amd64.tar.gz"
      sha256 "20c5309412e9db00c58871233e03983d47d318c2583895441640d3cc50a0ef8a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1536/agentshield_0.2.1536_darwin_arm64.tar.gz"
      sha256 "681ceeac38413394d0a194d99a9296cd9cd06d9d2381052d1193113a08b613f3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1536/agentshield_0.2.1536_linux_amd64.tar.gz"
      sha256 "b1b6b2718dc9712d6bb2e1187f204b080f15f9422e39e3c848ce5e50c42c6c58"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1536/agentshield_0.2.1536_linux_arm64.tar.gz"
      sha256 "0444ba3d5d544accd8c868d6e59c7739721e885cda57d1e6b01d9f0eb4e5b603"
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
