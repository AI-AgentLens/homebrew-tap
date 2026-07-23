cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1717"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1717/agentshield_0.2.1717_darwin_amd64.tar.gz"
      sha256 "afb4d0baf16d0c27d3e36153f84c405588fd3f009822ed0433921060c12ba2ee"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1717/agentshield_0.2.1717_darwin_arm64.tar.gz"
      sha256 "831e41bc16869d76ec50144a7759b9db6f80f6b2bd2a21a64fe80daf2e95a857"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1717/agentshield_0.2.1717_linux_amd64.tar.gz"
      sha256 "67e93094a298864cfaf8edf613081dd794019623d7aceb16e4ab7d9252f9465e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1717/agentshield_0.2.1717_linux_arm64.tar.gz"
      sha256 "ce41224f743f8df8fcf0c55ef45f4173c32b408db8ac23189b2bca5d45ee0f8c"
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
