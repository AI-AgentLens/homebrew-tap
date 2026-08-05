cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1794"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1794/agentshield_0.2.1794_darwin_amd64.tar.gz"
      sha256 "9cb490cb1c3e26c1a313ac87fcf9cd09d21865e335632a378d2ae2cc7987af37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1794/agentshield_0.2.1794_darwin_arm64.tar.gz"
      sha256 "9c8af1fd494dcf5216a2e48af77cb2ddda613375809c2289fd260c9a21a4bdcc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1794/agentshield_0.2.1794_linux_amd64.tar.gz"
      sha256 "46b9506bc4130c39a7906284f53f617cf080992457ef3f283650d5dc852ef9f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1794/agentshield_0.2.1794_linux_arm64.tar.gz"
      sha256 "3b70806b3db8ae07d2b4a8c8081958fc70533d24e4c8d7cd9df52c7ccdc6803a"
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
