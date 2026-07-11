cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1613"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1613/agentshield_0.2.1613_darwin_amd64.tar.gz"
      sha256 "ca84b077a03767a8b3e1af42a479986ad21fcc881dfdc15ae97cb6ac976dc9e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1613/agentshield_0.2.1613_darwin_arm64.tar.gz"
      sha256 "cd708662ade95f0d5b6d6029af8749fbab5d12c35b3fbdb03f6119fc7307dc26"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1613/agentshield_0.2.1613_linux_amd64.tar.gz"
      sha256 "0938920d6b58f2a0548a60a9d5830ceb83567b2de27d02634dd482f8a363c7a2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1613/agentshield_0.2.1613_linux_arm64.tar.gz"
      sha256 "a7a1b0755a53cc8a053f2e3a5d25a0ca925f05f86c0e948a6396eb690fa28886"
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
