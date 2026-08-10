cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1806"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1806/agentshield_0.2.1806_darwin_amd64.tar.gz"
      sha256 "d4d38b28a7556d39e8388e59a4b5d98797593d5e5af7f7544d2c1c4fab411d9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1806/agentshield_0.2.1806_darwin_arm64.tar.gz"
      sha256 "affc2e5528bea2a9861c7b2a8e7dbede8849fb2687796195b14958036ac5089e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1806/agentshield_0.2.1806_linux_amd64.tar.gz"
      sha256 "74a6b2eaba6f8dcb8584c27a6eef019c4823048fe17d3a1c36e27a4ee476c838"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1806/agentshield_0.2.1806_linux_arm64.tar.gz"
      sha256 "c8faa2570635de2bbefe71b6076ba54b122ca29a444ec2d68c6837f2bb65dc71"
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
