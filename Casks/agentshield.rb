cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2285"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2285/agentshield_0.2.2285_darwin_amd64.tar.gz"
      sha256 "1fe09955324feae74356b8a2254c5a1be4e8fd593b6dfcbff2ad4a295380b8b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2285/agentshield_0.2.2285_darwin_arm64.tar.gz"
      sha256 "adcd79890850f3b154aebfc83f199c1a7fa545e254c0e7a3921b770503aebc75"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2285/agentshield_0.2.2285_linux_amd64.tar.gz"
      sha256 "600afdde9476e6d2f30afed54bbb7c07fffab0dc6e92f95ce6e63b9d13098b9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2285/agentshield_0.2.2285_linux_arm64.tar.gz"
      sha256 "bfa9edf5c0ca99ee2d4ab8f28f1a6b0b55e3cb1f5beb46bedde2178fd333fb60"
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
