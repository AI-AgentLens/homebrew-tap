cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.978"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.978/agentshield_0.2.978_darwin_amd64.tar.gz"
      sha256 "3047123da5087ee335e2c4e998ab050a8c3da847bce412c3b16d7d0f97a0941b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.978/agentshield_0.2.978_darwin_arm64.tar.gz"
      sha256 "6e371e6a46b10478ddd07deca6129ca12b002657c6b3e2febe74dc2c6dffd9cc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.978/agentshield_0.2.978_linux_amd64.tar.gz"
      sha256 "fbbfa1541587589cb078c76c6ccbb63494908b8dc44eda141f4d7185424cf10f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.978/agentshield_0.2.978_linux_arm64.tar.gz"
      sha256 "8dc27f0229d89239a82fa908cd7b83ebf85cc2e392923355a3d387ed7d2797ae"
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
