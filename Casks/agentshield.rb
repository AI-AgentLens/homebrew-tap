cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2177"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2177/agentshield_0.2.2177_darwin_amd64.tar.gz"
      sha256 "fa6864a489387ac862ffbd9c59eb300d8b8ce310df640c22b21e3dc4c8fe9f61"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2177/agentshield_0.2.2177_darwin_arm64.tar.gz"
      sha256 "fb6ddc79617f0a6cef87623693343a333339a2edc78c3ced4f83807cf01adc0c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2177/agentshield_0.2.2177_linux_amd64.tar.gz"
      sha256 "826e9d25e2243dc9982f971b101a361c336bbaadd85b14741a86e5aba9d711da"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2177/agentshield_0.2.2177_linux_arm64.tar.gz"
      sha256 "9f9c0382b3ea31e2c9e50a1b37137a465fc62e4c555c279b2066a3f19520b848"
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
