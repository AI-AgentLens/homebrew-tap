cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2108"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2108/agentshield_0.2.2108_darwin_amd64.tar.gz"
      sha256 "7833e091ce6baded31edb97efb183267d149c2d138d0972b4321948894c0ff2e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2108/agentshield_0.2.2108_darwin_arm64.tar.gz"
      sha256 "87b77018079d2a2e82630e947b318b1b63058b9ff5178b71134cbe3ac4d77f93"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2108/agentshield_0.2.2108_linux_amd64.tar.gz"
      sha256 "409039031e479638dcccf24a96699f2f054e476f8035ac7318c5e5f812e42a13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2108/agentshield_0.2.2108_linux_arm64.tar.gz"
      sha256 "235d52c6aeb38f26cc85fb888ccc04d359f9f799f5c33d57d808483bec9a6272"
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
