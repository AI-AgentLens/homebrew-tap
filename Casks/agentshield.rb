cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.103"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.103/agentshield_0.2.103_darwin_amd64.tar.gz"
      sha256 "71404a49d194c954bcc8512a359f72e2e226b037b9fa33b9b3803b010ca13f64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.103/agentshield_0.2.103_darwin_arm64.tar.gz"
      sha256 "d465b2d879fc3750feaa2a62bcc71175d46ae6144d017779a030849323ada00d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.103/agentshield_0.2.103_linux_amd64.tar.gz"
      sha256 "feaa3bad649ac7ba5af7ba8301d7a4e97847aa83dfa128e8e26eb3e19fec9d64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.103/agentshield_0.2.103_linux_arm64.tar.gz"
      sha256 "43604db67567cdf743709d8cfea4fb7d5fdde418cc10ba4cb1ca5673d9370c92"
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
